# LENS Step-by-Step Claude CLI Runbook

## 1. Merge the package

Extract the ZIP into:

`D:\lara\www\lens`

Merge folders when prompted. Do not delete existing source code.

## 2. Review the addendum

Merge the important rules from `CLAUDE-LENS-ADDENDUM.md` into the root `CLAUDE.md`, or instruct Claude to read both files.

## 3. Start Claude

```powershell
cd D:\lara\www\lens
claude
```

## 4. Run the first baseline task

```text
/implement-work-package docs/work-packages/phase-00/WP-00-01-project-baseline.md
```

## 5. Verify it

```text
/verify-work-package docs/work-packages/phase-00/WP-00-01-project-baseline.md
```

## 6. Commit and clear

Commit the completed work package using Git, then:

```text
/clear
```

## 7. Continue in order

Follow `docs/EXECUTION-ORDER.md`.

## Laravel-only execution

```text
/implement-laravel-section docs/work-packages/phase-XX/WP-XX-XX-task.md
```

## Flutter-only execution

```text
/implement-flutter-section docs/work-packages/phase-XX/WP-XX-XX-task.md
```

## Important token-saving rules

- One work package per session.
- One codebase per session when possible.
- Use `/clear` after each completed package.
- Run targeted tests, not full suites, during routine tasks.
- Do not ask Claude to inspect the entire repository.
- Do not install additional skills, agents, or MCP servers unless a real need appears.
