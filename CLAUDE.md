# LENS Development Rules

## Project

LENS is a Digital School System with:

- Laravel 13 backend and REST API
- Flutter Android application
- MySQL database

## Core Working Rules

- Work only on the assigned work package.
- Read the work package before inspecting source files.
- Search for relevant symbols before opening complete files.
- Inspect only files directly related to the task.
- Do not scan the whole repository unless explicitly requested.
- Do not install packages unless the work package requires them.
- Never expose or commit secrets, credentials, tokens, or `.env` files.
- Ask before destructive database operations.
- Keep terminal output concise; report failures and final results only.

## Verification Before Completion

1. Review the final diff.
2. Confirm the implementation matches the work package.
3. Run targeted backend tests.
4. Run Flutter formatting, analysis, and targeted tests when mobile files changed.
5. Report changed files, commands run, migrations required, and unresolved risks.
6. Update only the assigned work package status and implementation notes.
