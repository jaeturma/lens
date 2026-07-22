# Announcements

## Model and Lifecycle (WP-05-01)

`announcements` (`App\Models\Announcement`): `uuid` (stable sync ID, same
pattern as `Student`/`Guardian`/`GuardianStudentLink` — immutable once
set), `title`, `body`, `author_id` (nullable FK to `users`,
`nullOnDelete`), `status` (`App\Enums\AnnouncementStatus`: `Draft`,
`Published`, `Expired`, `Withdrawn`), `published_at` (nullable, set only
when actually published — not an admin-settable future schedule time),
`expires_at` (nullable, admin-settable). New rows default to `Draft` if
`status` isn't given explicitly.

### Lifecycle

Only two admin-triggered transitions exist, each its own focused Action,
and each rejects an invalid starting state via
`App\Exceptions\Announcements\InvalidAnnouncementTransitionException`:

- `App\Actions\Announcements\PublishAnnouncement` — `Draft` → `Published`
  only; records `published_at` as of now.
- `App\Actions\Announcements\WithdrawAnnouncement` — `Published` →
  `Withdrawn` only; a `Draft` was never visible to withdraw, `Expired`/
  `Withdrawn` are terminal.

A third transition is automatic, not admin-triggered:

- `App\Actions\Announcements\ExpireDueAnnouncements` — every `Published`
  announcement whose `expires_at` has passed becomes `Expired`. Only
  ever considers `Published` rows (a `Draft` has no meaningful
  expiration; `Withdrawn`/`Expired` are already terminal). Driven by the
  `announcements:expire` console command, scheduled every 15 minutes
  (`routes/console.php`) — `expires_at` is an admin-set instant, not a
  fixed daily clock time, so this polls rather than running once, mirroring
  `attendance:mark-absences`'s (WP-04-04) reasoning exactly.

`Withdrawn` and `Expired` are both terminal: there is no transition back
to `Published` from either. A withdrawn or expired announcement that
should run again is a new announcement, not a resurrected one — not built,
since nothing asked for it.

### Sync Feed and Draft Invisibility

`App\Observers\AnnouncementObserver` (registered `#[ObservedBy]`, morph
map alias `announcement` in `App\Providers\AppServiceProvider`) enforces
"drafts are not parent-visible" **at the sync-feed layer**, not left to a
future guardian-scoping branch that could accidentally leak one:

- While `status` is `Draft` — on creation or any edit — no `sync_changes`
  row is written at all.
- The first sync entry for an announcement is recorded the moment it
  first leaves `Draft` (i.e., publish), as `SyncChangeAction::Created` —
  not literally when the database row was created, since a guardian's
  client has never seen it before that point regardless of the row's real
  age.
- Withdrawing records `SyncChangeAction::Revoked` (mirroring
  `guardian_student_link`'s revoke-as-tombstone precedent from WP-02-03),
  and automatic expiration records `SyncChangeAction::Expired` — both let
  a future client special-case removal rather than diffing fields.
  Ordinary edits to an already-published announcement record the generic
  `Updated`.
- **No guardian can see any of this yet.** `App\Actions\Sync\ScopeChangesToGuardian`
  has no `announcement` branch — every announcement entry is currently
  denied by default (unknown resource type), same deferred-visibility gap
  WP-04-02 left for attendance until WP-04-06 closed it. Guardian-scoped
  audience targeting is WP-05-03/05-04's job.

## Administration (WP-05-02)

Administrator-only web screens under `/announcements`
(`App\Http\Controllers\Announcements\*`, `App\Policies\AnnouncementPolicy`
— `isAdministrator()`, same gate every other admin resource uses):

- `AnnouncementController` (`index`/`create`/`store`/`show`/`edit`/
  `update`) — ordinary CRUD, mirroring `StudentController`/
  `RfidDeviceController` exactly. `store` always creates a `Draft`
  (`author_id` set from the acting user) — there is no way to create an
  announcement in any other status from the form. `update` touches
  `title`/`body`/`expires_at`, and (WP-05-03) the audience fields; status
  never changes through this endpoint.
- Three single-purpose action controllers —
  `PublishAnnouncementController`, `WithdrawAnnouncementController`,
  `ExpireAnnouncementController` — call the WP-05-01 actions (plus a new
  `App\Actions\Announcements\ExpireAnnouncement` for a manual,
  admin-triggered expire; see below) and catch
  `InvalidAnnouncementTransitionException`, converting it to a normal
  `422` validation error instead of a `500`.
- Every mutation (create, edit, publish, withdraw, expire) calls
  `App\Actions\Audit\RecordAuditLog` **from the controller**, not from
  inside the WP-05-01 actions — matching `StudentController`/
  `RfidDeviceController`'s convention (not `AssignRfidCard`/
  `ReplaceRfidCard`'s, which self-audit); the two lifecycle action classes
  stay audit-agnostic and unchanged from WP-05-01.

### Manual vs. Automatic Expiration

Two different ways an announcement reaches `Expired`, both valid only
from `Published`:

- `App\Actions\Announcements\ExpireDueAnnouncements` (WP-05-01) — bulk,
  scheduled, only considers announcements whose `expires_at` has actually
  passed.
- `App\Actions\Announcements\ExpireAnnouncement` (WP-05-02, new) —
  single, admin-triggered, works even with no `expires_at` set at all
  (e.g. "this is no longer relevant, retire it now"). "Administrators can
  ... expire" is one of WP-05-02's own acceptance criteria, distinct from
  the scheduled sweep.

## Audiences (WP-05-03)

Every announcement targets exactly one audience
(`App\Enums\AnnouncementAudienceType`: `All`, `Grade`, `Section`,
`Students` — new columns `audience_type`/`audience_grade`/
`audience_section` on `announcements`, default `All`), resolved without
any campaign/segment-building complexity:

- **All** — every active (`StudentStatus::Active`) student.
- **Grade** — active students whose `grade` matches `audience_grade`
  exactly (free-text, same convention as `Student.grade` elsewhere in the
  app — no separate grade/section lookup tables exist).
- **Section** — active students matching **both** `audience_grade` and
  `audience_section` — a section is only meaningful within a grade (two
  different grades can each have their own "Diamond" section), so
  targeting by section alone would be ambiguous.
- **Students** — an explicit set via the new `announcement_student` pivot
  table (`App\Models\Announcement::students()`, `BelongsToMany`), still
  filtered to active students only — a selected-but-since-withdrawn
  student's guardian is not targeted, keeping behavior consistent with
  the other three types rather than carving out an exception.

Two actions, both pure audience matching — **neither considers the
announcement's `status`**, that's a separate concern layered on by the
caller (WP-05-04):

- `App\Actions\Announcements\ResolveAnnouncementAudience` — an
  announcement to its matching active student IDs.
- `App\Actions\Announcements\GuardianMatchesAnnouncementAudience` — an
  announcement and a guardian to a boolean: does the audience overlap the
  guardian's **currently active** linked students
  (`Guardian::activeLinks()`, the same "currently active" rule
  `ScopeChangesToGuardian` already applies for attendance, WP-04-06).
  Revoking a link removes that student from `activeLinks()` immediately,
  so a revoked link stops matching on the very next call — no caching, no
  separate cleanup step.
- Audience selection was added to the WP-05-02 create/edit forms (a
  native `<select multiple>` for the Students case — no new component or
  package, matching "without campaign-level complexity").

## Parent Announcement Sync Contract (WP-05-04)

Guardians now see audience-matching announcements over the mobile sync
API — see `docs/api/SYNC.md`'s `announcement` section for the full
contract (payload shape, stable ID, local deletion behavior, and the
bootstrap/incremental split). Summary of what changed:

- `App\Actions\Sync\ScopeChangesToGuardian` gained an `announcement`
  branch: re-resolves `GuardianMatchesAnnouncementAudience` against the
  **live** `Announcement` (via the change's polymorphic `resource`
  relation), not a stale payload snapshot — audience/pivot membership can
  change after the sync entry was written. A `Draft` never reaches this
  branch (the observer already never records one).
- Bootstrap's response gained a top-level `announcements` array — every
  currently `Published` announcement matching any of the guardian's
  active linked students, resolved fresh on every call (not a per-child
  field, since one announcement can match through several children).
- **Local deletion, decided**: withdrawn/expired announcements are
  **removed locally**, not kept-but-hidden — both `revoked` (withdraw)
  and `expired` (both expiration paths) were already tombstone actions
  per the existing "Tombstones" convention (WP-01-07), so this package
  just confirmed announcements follow it rather than inventing an
  archive/history feature nothing asked for.

phase 5 (Announcements) is now complete — all four work packages
(WP-05-01 through WP-05-04) are implemented (Laravel/API layer; Flutter
consumption of this contract is separate follow-up work, same split
WP-04-06 used for attendance).
