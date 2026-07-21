# LENS Architecture

## Components

1. Laravel 13 web application and REST API
2. MySQL database
3. Flutter Android parent application
4. RFID readers posting scans to Laravel
5. Firebase Cloud Messaging for push delivery

## Main Flow

RFID Reader -> Laravel scan endpoint -> raw scan record -> attendance processor -> attendance event and daily summary -> notification record -> Firebase -> Flutter app.

## Important Boundaries

- Raw RFID scans are immutable source records.
- Attendance events are processed interpretations of raw scans.
- Daily attendance summaries may be corrected without deleting raw scans.
- Parent mobile authentication is separate from RFID device authentication.
- Laravel remains the source of truth.
