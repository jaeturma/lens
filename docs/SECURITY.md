# LENS Security Baseline

- Use Laravel Sanctum for parent mobile sessions.
- Use a separate credential model for RFID devices.
- Hash secrets at rest where possible.
- Rate-limit login and device scan endpoints.
- Authorize every administrative action.
- Prevent guardians from accessing unlinked students.
- Audit sensitive changes.
- Validate device timestamps and handle replay or duplicate scans.
- Do not expose student data unnecessarily.
- Store push tokens securely and allow revocation.
