---
name: verify-task
description: Verify a completed work package against acceptance criteria without expanding scope.
argument-hint: <path-to-work-package>
---

Verify `$ARGUMENTS`.

## Procedure

1. Read the work package and its acceptance criteria.
2. Inspect `git status`, the focused diff, and relevant implementation files.
3. Map each acceptance criterion to code and tests.
4. Run only the relevant tests, analysis, and formatting checks.
5. Fix confirmed defects only when the correction is clearly within scope.
6. Do not add enhancements or refactor unrelated files.
7. Update verification notes in the work package.
8. Report:
   - passed criteria
   - failed or unverified criteria
   - tests and checks run
   - files changed during verification
   - remaining risks
