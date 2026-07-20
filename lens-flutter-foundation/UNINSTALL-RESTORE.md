# Restore the previous Flutter sample

The installer creates a directory similar to:

```text
mobile\_foundation_backup_20260719-193000
```

To restore manually:

1. Delete the current `mobile\lib` and `mobile\test` folders.
2. Copy `lib` and `test` from the selected backup directory back into `mobile`.
3. Remove the four added dependencies from `mobile\pubspec.yaml` if no longer needed.
4. Run `flutter pub get`.
