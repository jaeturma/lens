---
name: implement-api
description: Implement one bounded Laravel 13 API work package with focused tests and minimal repository inspection.
argument-hint: <path-to-work-package>
---

Implement the Laravel API requirements in `$ARGUMENTS`.

## Procedure

1. Read `CLAUDE.md`, applicable `.claude/rules/`, and the specified work package.
2. Search for related route names, models, controllers, actions, requests, resources, policies, and tests.
3. Open only the minimum relevant files.
4. Present a concise plan containing:
   - files likely to change
   - database impact
   - endpoint and authorization impact
   - focused tests to run
5. Implement only the stated scope.
6. Add or update focused Pest tests.
7. Run formatting on changed PHP files when available.
8. Run the smallest relevant test command.
9. Review the diff against every acceptance criterion.
10. Update the work package implementation notes.
11. Report changed files, tests, commands the user must run, and remaining risks.

Do not add mobile implementation unless the work package explicitly includes it.
