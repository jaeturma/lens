# Announcements API

Defines targeted active announcements, expiration, and synchronization behavior.

## Status (WP-05-01)

No HTTP endpoint exists yet — this package built the model and lifecycle
only (`App\Models\Announcement`, `App\Enums\AnnouncementStatus`: `draft`/
`published`/`expired`/`withdrawn`). See `docs/ANNOUNCEMENTS.md` for the
full lifecycle contract, the sync-feed shape, and why drafts never reach
`sync_changes`. Admin CRUD endpoints (WP-05-02), audience targeting
(WP-05-03), and the guardian-facing bootstrap/incremental sync contract
(WP-05-04) are not built yet.
