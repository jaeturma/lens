# LENS Development Rules v1.1

Use this together with the root `CLAUDE.md`.

## Product Objective

Build a school-bound, offline-first parent application and Laravel backend where:

- the first mobile launch requires a valid School ID;
- the school binding is locked for that installation;
- logout never removes the School ID;
- uninstall and reinstall reset the binding;
- Flutter screens read from SQLite;
- Laravel provides incremental synchronization;
- RFID scans produce attendance events;
- parents receive attendance and announcement notifications;
- school administrators manage students, guardians, RFID, attendance, and announcements.

## Scope Rules

- Work only on the assigned work package and requested layer.
- Inspect the minimum relevant files.
- Do not scan the full repository without a direct need.
- Do not add teacher, student, grading, LMS, payment, AI, transport, inventory, guidance, or booking modules.
- Do not introduce multi-school switching in one app installation.
- Do not add a visible School ID reset function.
- Do not treat push payloads as the authoritative record.
- Do not make Flutter screens depend directly on live API responses.

## Laravel Rules

- API prefix: `/api/v1`.
- Use Form Requests, API Resources, Policies, focused Actions/Services, transactions, and Pest.
- Parent authentication is school-bound.
- RFID device authentication is separate from user authentication.
- Raw RFID scans are immutable.
- Incremental sync must include creates, updates, deletions, revocations, expirations, and corrections.
- Sync cursors are committed only after a successful server-side change set is produced.
- Expose minimum supported mobile version and maintenance state.

## Flutter Rules

- Work inside `mobile/`.
- Use the existing Riverpod, GoRouter, Dio, and secure storage foundation.
- Use Drift for SQLite unless the project already has an approved SQLite package.
- SQLite is the mobile source of truth.
- Repositories write API changes into SQLite; screens observe SQLite.
- Save a sync cursor only after a complete local transaction succeeds.
- School binding survives logout and app restart.
- Android Auto Backup must not restore the school binding or application database after uninstall.
- Handle loading, empty, offline, stale, error, and success states.
- Run `dart format`, targeted tests, and `flutter analyze`.

## Completion Report

Report:

1. files changed;
2. migrations and local database changes;
3. API contracts;
4. tests and analysis;
5. commands the user must run;
6. remaining risks or manual checks.
