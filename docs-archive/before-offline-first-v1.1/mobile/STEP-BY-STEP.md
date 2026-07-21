# LENS Flutter Step-by-Step Execution

## Step 1 — Validate the installed foundation

```powershell
cd D:\lara\www\lens\mobile
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Start the emulator and run:

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

Expected screen: **Foundation Ready**.

## Step 2 — Establish the Laravel API baseline

Run the work package in a new Claude Code session from `D:\lara\www\lens`:

```text
Implement only docs/mobile/work-packages/WP-MOB-00-01-api-contract-baseline.md.

Work mainly in Laravel. Do not build Flutter screens. Inspect only the minimum files required. Document the current authentication and API response conventions, implement only missing baseline requirements stated in the work package, run targeted Pest tests, and report the final API contract.
```

After completion:

```text
/clear
```

## Step 3 — Implement Flutter authentication

```text
/implement-flutter-feature docs/mobile/work-packages/WP-MOB-01-01-authentication.md
```

After implementation:

```text
/verify-flutter-task docs/mobile/work-packages/WP-MOB-01-01-authentication.md
```

Then:

```text
/clear
```

## Ongoing rule

Use one bounded work package per Claude session. Do not ask Claude to implement an entire module across Laravel and Flutter in one task unless the API contract is genuinely inseparable.
