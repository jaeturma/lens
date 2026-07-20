# LENS Database Baseline

Expected initial entities:

- users
- roles and permissions
- schools
- school_settings
- students
- guardians
- guardian_student
- rfid_devices
- rfid_cards
- rfid_scans
- attendance_events
- attendance_daily_summaries
- attendance_rules
- announcements
- announcement_audiences
- notifications
- mobile_device_tokens
- audit_logs

## Principles

- Use foreign keys where appropriate.
- Use unique indexes for LRN, device code, active RFID UID, and relevant tokens.
- Use soft deletes only when recovery is useful.
- Preserve raw scan history.
- Use explicit status fields instead of ambiguous booleans.
- Store timestamps in a consistent timezone strategy.
