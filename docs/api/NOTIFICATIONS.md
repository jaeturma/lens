# Notifications API

Defines notification inbox, unread count, read state, device token registration, and push delivery logging.

## Status (WP-06-01)

No HTTP endpoint exists yet — this package built the model only
(`App\Models\GuardianNotification`, table `guardian_notifications` —
deliberately not `notifications`, see `docs/NOTIFICATIONS.md` for why).
No rule creates a notification yet (WP-06-02/06-03), no guardian can see
one over sync yet (WP-06-06), and no push delivery exists yet
(WP-06-04/06-05).
