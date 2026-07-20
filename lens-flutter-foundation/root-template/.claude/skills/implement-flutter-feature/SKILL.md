---
name: implement-flutter-feature
description: Implement one bounded LENS Flutter work package with minimal repository inspection.
---

1. Read the specified work package and `docs/mobile/MOBILE-ARCHITECTURE.md`.
2. Inspect only directly related files inside `mobile/` and the documented API contract.
3. Do not inspect Laravel implementation files unless the API contract is missing or contradictory.
4. Present a concise plan listing affected files before editing.
5. Reuse Riverpod, GoRouter, Dio, secure storage, theme and shared widgets already installed.
6. Do not add a package unless the work package cannot reasonably be completed without it.
7. Implement loading, empty, error and success states where applicable.
8. Run `dart format`, targeted tests and `flutter analyze`.
9. Review the diff against acceptance criteria.
10. Report changed files, commands run, passed criteria and unresolved risks.
