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
