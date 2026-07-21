# Offline and Incremental Synchronization

## Source of Truth

Laravel is the server source of truth. SQLite is the mobile runtime source of truth.

## Local Resources

- app settings
- school profile
- guardian profile
- linked students
- attendance records
- announcements
- notifications
- sync state
- mobile device state

## Sync Triggers

- successful login
- application startup
- application resume
- pull-to-refresh
- push notification signal
- explicit retry after connection recovery

## Cursor Rules

- Do not rely only on client timestamps.
- Laravel returns an opaque cursor or monotonic change sequence.
- Flutter saves the next cursor only after the full SQLite transaction succeeds.
- Failed sync leaves the previous cursor unchanged.
- A sync request carrying only a client timestamp, with no valid cursor, is
  rejected; the cursor is the only accepted position marker.

## Change Types

- create
- update
- delete
- revoke
- expire
- attendance correction
- notification read-state update

## Bootstrap

A first authenticated bootstrap may download all currently relevant guardian data. Later calls use incremental synchronization.

## Offline Behavior

Previously synchronized school, child, attendance, announcement, and notification data remains readable without internet.
