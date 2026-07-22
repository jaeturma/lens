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
- No mobile/device-facing HTTP contract exists yet. Audience targeting
  (WP-05-03) and the guardian-facing bootstrap/incremental sync contract
  (WP-05-04) are not built.
