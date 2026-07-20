# LENS Development Rules

## Project

LENS is a Digital School System with:

- Laravel 13 backend and REST API
- Flutter Android application
- MySQL database

Adjust paths below to match the actual repository:

- Laravel root: current repository root
- Flutter app: `mobile/`
- Work packages: `docs/work-packages/`

## Core Working Rules

- Work only on the assigned work package.
- Read the work package before inspecting source files.
- Search for relevant symbols before opening complete files.
- Inspect only files directly related to the task.
- Do not scan the whole repository unless explicitly requested.
- Follow existing project patterns before introducing new abstractions.
- Keep implementations simple, secure, and maintainable.
- Do not add speculative features.
- Do not refactor unrelated code.
- Do not install packages unless the work package requires them.
- Never expose or commit secrets, credentials, tokens, or `.env` files.
- Ask before destructive database operations.
- Keep terminal output concise; report failures and final results only.

## Laravel 13 Rules

- Use Form Requests for validation.
- Use API Resources for API responses.
- Use Policies or Gates for authorization.
- Keep controllers thin.
- Put non-trivial business logic in focused Actions or Services.
- Use database transactions for multi-record writes.
- Use eager loading where it prevents N+1 queries.
- Add indexes for frequently filtered foreign keys and status/date fields.
- Use Laravel Sanctum for mobile API authentication unless the project already uses another approved method.
- Add focused Pest tests for changed backend behavior.
- Prefer targeted tests during development.

## Flutter Rules

- Use the existing state-management solution.
- Follow a feature-first directory structure when adding new modules.
- Keep API, repository, state, and UI responsibilities separated.
- Reuse existing widgets, theme components, and error handlers.
- Handle loading, empty, error, offline, and success states when relevant.
- Use secure storage for authentication tokens.
- Do not add a new package if existing dependencies can perform the task.
- Run formatting and analysis on affected code.

## API Rules

- Version endpoints under `/api/v1` unless the existing project uses another version.
- Return consistent JSON response structures.
- Use correct HTTP status codes.
- Do not expose stack traces or internal exception messages.
- Do not silently change an existing API contract.
- Document request and response changes in the assigned work package.

## Verification Before Completion

1. Review the final diff.
2. Confirm the implementation matches the work package.
3. Run targeted backend tests.
4. Run Flutter formatting, analysis, and targeted tests when mobile files changed.
5. Report changed files, commands run, migrations required, and unresolved risks.
6. Update only the assigned work package status and implementation notes.
