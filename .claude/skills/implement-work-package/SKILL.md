---
name: implement-work-package
description: Implement one bounded LENS work package or one explicitly requested section of it.
---

1. Read the specified work package.
2. Read only the core documents directly relevant to it.
3. Inspect the minimum files needed.
4. State a concise implementation plan and affected files.
5. Implement only the assigned scope.
6. Do not add excluded features.
7. Run targeted tests and analysis.
8. Review the diff against acceptance criteria.
9. Update the work package implementation notes.
10. Report changed files, tests, commands, and remaining risks.

When a package affects both Laravel and Flutter, implement only the section explicitly requested by the user. Do not inspect the other codebase unless the documented contract is missing or contradictory.
