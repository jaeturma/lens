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

### Not Yet Implemented

No admin UI/API exists yet — announcements exist and are usable now as
ordinary Eloquent data plus the two lifecycle actions, callable from code
or `tinker`, same "usable now, edit surface is a future package's job"
precedent WP-04-01 set for `AttendanceRule`. Administration (create/edit/
publish/withdraw screens, authorization, audit logging — WP-05-02),
audience targeting (WP-05-03), and the guardian-facing sync contract
(WP-05-04) are the remaining phase-05 work packages.
