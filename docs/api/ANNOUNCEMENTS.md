# Announcements API

Defines targeted active announcements, expiration, and synchronization behavior.

## Status

- WP-05-01 built the model and lifecycle (`App\Models\Announcement`,
  `App\Enums\AnnouncementStatus`: `draft`/`published`/`expired`/
  `withdrawn`). See `docs/ANNOUNCEMENTS.md` for the full lifecycle
  contract, the sync-feed shape, and why drafts never reach
  `sync_changes`.
- WP-05-02 added administrator-only **web** screens under
  `/announcements` (Inertia, session-authenticated) — not a JSON/mobile
  API. See `docs/ANNOUNCEMENTS.md`'s "Administration" section.
- WP-05-03 added audience targeting (all/grade/section/selected students)
  and resolution logic, exposed through the same admin web forms — still
  no mobile/device-facing HTTP contract. See `docs/ANNOUNCEMENTS.md`'s
  "Audiences" section.
- No mobile/device-facing HTTP contract exists yet. The guardian-facing
  bootstrap/incremental sync contract (WP-05-04) is not built.
