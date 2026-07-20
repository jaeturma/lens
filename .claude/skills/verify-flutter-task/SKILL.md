---
name: verify-flutter-task
description: Verify a completed LENS Flutter work package without expanding its scope.
---

1. Read the specified work package.
2. Inspect only changed files, directly related tests and the documented API contract.
3. Verify every acceptance criterion with evidence.
4. Fix only confirmed defects within scope.
5. Do not redesign architecture or add enhancements.
6. Run formatting, targeted tests and `flutter analyze`.
7. Report pass/fail per acceptance criterion and any remaining risk.
