# Database Baseline

## Laravel/MySQL

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
- attendance_rules
- attendance_events
- attendance_daily_summaries
- announcements
- announcement_audiences
- notifications
- mobile_device_tokens
- sync_changes or equivalent change feed
- audit_logs

## Flutter/SQLite

- app_settings
- school_profile
- guardian_profile
- students
- guardian_student_links
- attendance_records
- announcements
- notifications
- sync_state
- mobile_device_state

## Rules

- public School ID resolves to an immutable school UUID;
- raw RFID scans are preserved;
- synchronized resources expose stable IDs and versions;
- deletions and revocations use tombstones or equivalent sync events;
- unique indexes protect LRN, device code, active RFID UID, and device tokens.
