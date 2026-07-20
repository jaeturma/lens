# LENS Unified Development Rules

Use this file together with the existing root `CLAUDE.md`.

## Product Goal

Build a focused Digital School System where:

- school administrators organize students and guardians;
- RFID readers submit student scans to Laravel;
- Laravel processes arrival, departure, late, absence, and duplicate events;
- parents or guardians log in using Flutter;
- parents receive attendance notifications and school announcements.

## Scope Discipline

- Work only on the assigned work package and assigned section.
- Do not add teacher, student, grading, LMS, payment, AI, transport, inventory, or guidance modules.
- Do not redesign unrelated code.
- Do not introduce a package unless the work package clearly requires it.
- Use existing Laravel and Flutter patterns where they are sound.
- Inspect the minimum relevant files.
- Use search before opening large files.
- Keep command output concise.
- Run targeted tests before full suites.

## Laravel Rules

- API prefix: `/api/v1`.
- Use Form Requests for validation.
- Use API Resources for mobile-facing JSON.
- Use Policies or Gates for authorization.
- Keep controllers thin.
- Use focused Actions or Services for business rules.
- Preserve raw RFID scans.
- Never overwrite or delete raw scans when correcting attendance.
- Use database transactions for multi-record changes.
- Add Pest tests for changed behavior.

## Flutter Rules

- Work inside `mobile/`.
- Use the existing feature-first foundation.
- Use Riverpod, GoRouter, Dio, and secure storage already installed.
- Handle loading, empty, error, and success states.
- Keep API contracts documented.
- Run `dart format`, targeted tests, and `flutter analyze`.

## Completion Report

Every task must report:

1. Files changed
2. Database changes
3. Routes or API contracts added or changed
4. Tests and analysis executed
5. Commands the user must run
6. Remaining risks or blocked items
