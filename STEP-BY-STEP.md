# Claude CLI Runbook

## 1. Archive the previous roadmap

Do not delete it immediately. Move the previous active documentation to a dated folder such as:

`docs-archive\before-offline-first-v1.1`

Keep the existing Flutter foundation files.

## 2. Merge this package

Extract this ZIP into:

`D:\lara\www\lens`

## 3. Update root instructions

Merge the permanent rules in `CLAUDE-LENS-ADDENDUM.md` into the root `CLAUDE.md`, or always tell Claude to read both.

## 4. Start Claude

```powershell
cd D:\lara\www\lens
claude
```

## 5. Execute one package

```text
/implement-work-package docs/work-packages/phase-00/WP-00-01-project-baseline.md
```

## 6. Verify

```text
/verify-work-package docs/work-packages/phase-00/WP-00-01-project-baseline.md
```

## 7. Commit and clear

Commit the completed package, then:

```text
/clear
```

## Laravel-only section

```text
/implement-laravel-section <work-package-path>
```

## Flutter-only section

```text
/implement-flutter-section <work-package-path>
```

## Token-saving rules

- one work package per session;
- one codebase per session where possible;
- Laravel contract first, Flutter implementation second;
- use targeted tests;
- never request a full repository review unless the baseline package requires it;
- do not install more agents, skills, or MCP servers until a concrete need appears.
