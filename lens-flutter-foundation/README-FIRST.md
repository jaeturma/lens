# LENS Flutter Professional Foundation

This package installs a minimal professional Flutter foundation into an existing LENS workspace.

Expected project layout:

```text
D:\lara\www\lens\
├── app\                 Laravel 13
├── mobile\              Existing Flutter Android project
├── docs\
├── .claude\
└── CLAUDE.md
```

## Install

1. Extract this package into:

```text
D:\lara\www\lens\_lens_flutter_foundation
```

2. Open PowerShell at:

```text
D:\lara\www\lens
```

3. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\_lens_flutter_foundation\install.ps1
```

4. Start the Android emulator.

5. Run:

```powershell
cd D:\lara\www\lens\mobile
flutter run
```

The installer creates a timestamped backup under `mobile\_foundation_backup_*` before replacing the default sample files.
