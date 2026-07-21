---
paths:
  - "app/**"
  - "bootstrap/**"
  - "config/**"
  - "database/**"
  - "resources/**"
  - "routes/**"
  - "tests/**"
---

# Backend Rule

Apply this rule when working on Laravel backend files.

- Inspect the route, request, controller/action, model, resource, policy, migration, and tests only when relevant.
- Reuse existing response helpers and naming conventions.
- Validate every externally supplied field.
- Authorize access before reading or changing protected records.
- Avoid placing business rules directly in routes or views.
- Use transactions for operations that must succeed or fail together.
- Avoid mass-assignment vulnerabilities.
- Do not return sensitive columns.
- Add or update focused Pest tests.
- Run the smallest relevant test set first.

## Laravel 13 Conventions

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

## API Rules

- Version endpoints under `/api/v1` unless the existing project uses another version.
- Return consistent JSON response structures.
- Use correct HTTP status codes.
- Do not expose stack traces or internal exception messages.
- Do not silently change an existing API contract.
- Document request and response changes in the assigned work package.
