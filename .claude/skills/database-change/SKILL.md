---
name: database-change
description: Safely implement one bounded Laravel database schema change with rollback and tests.
argument-hint: <path-to-work-package>
---

Implement the database requirements in `$ARGUMENTS`.

## Procedure

1. Read the work package and inspect only related models, migrations, seeders, factories, validation, and tests.
2. Check existing table names, column types, constraints, indexes, and data assumptions.
3. Present a short migration safety plan covering:
   - forward migration
   - rollback
   - existing-data compatibility
   - indexes and foreign keys
   - application changes required
4. Create additive, reversible migrations whenever possible.
5. Do not use destructive commands or modify old production migrations unless specifically required.
6. Update related models, factories, seeders, validation, and tests only as necessary.
7. Run migration status and focused tests.
8. Review the diff and update the work package.
9. Report deployment commands, backup considerations, and risks.
