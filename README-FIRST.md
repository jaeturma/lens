# LENS Unified Development Kit v1.1

This package replaces the earlier LENS work-phase package.

It provides one simple roadmap for:

- Laravel 13 school administration and REST API
- one-time School ID binding on first mobile launch
- locked school binding until application uninstall
- SQLite-first Flutter data storage
- incremental synchronization of new, updated, deleted, revoked, and expired records
- parent or guardian authentication
- student and guardian organization
- RFID devices, cards, scans, and attendance processing
- school announcements
- in-app notifications and Firebase push signals
- Google Play release preparation

## Install

Archive the previous active roadmap before merging this package.

Extract and merge into:

`D:\lara\www\lens`

Do not replace Laravel or Flutter source folders.

## Begin

```powershell
cd D:\lara\www\lens
claude
```

Then:

```text
/implement-work-package docs/work-packages/phase-00/WP-00-01-project-baseline.md
```

Verify:

```text
/verify-work-package docs/work-packages/phase-00/WP-00-01-project-baseline.md
```

Commit and run `/clear` before the next unrelated work package.
