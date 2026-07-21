---
paths:
  - "mobile/**"
---

# Flutter Rule

Apply this rule when working inside the Flutter application.

- Inspect only the relevant feature, shared networking layer, router, and theme files.
- Follow the existing state-management pattern.
- Keep transport models separate from domain or UI models when the project already follows this pattern.
- Centralize API error handling.
- Never hard-code production URLs, tokens, or credentials.
- Preserve accessibility, readable text sizes, and touch-friendly controls.
- Handle loading, validation, empty, error, and success states.
- Run `dart format` on changed Dart files.
- Run targeted tests and `flutter analyze`.

## Additional Flutter Conventions

- Use the existing state-management solution.
- Follow a feature-first directory structure when adding new modules.
- Keep API, repository, state, and UI responsibilities separated.
- Reuse existing widgets, theme components, and error handlers.
- Handle loading, empty, error, offline, and success states when relevant.
- Use secure storage for authentication tokens.
- Do not add a new package if existing dependencies can perform the task.
- Run formatting and analysis on affected code.
