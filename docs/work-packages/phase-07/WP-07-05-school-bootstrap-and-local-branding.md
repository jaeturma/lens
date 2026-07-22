# WP-07-05 — School Bootstrap and Local Branding

## Objective

Download and store mobile school configuration and branding.

## Affected Layers

- [ ] Laravel
- [ ] Database
- [x] API
- [x] Flutter
- [ ] Android
- [ ] RFID Integration

## Scope

Read the school profile from SQLite after the repository writes the bootstrap response.

## Out of Scope

Unrelated modules, speculative enhancements, and excluded initial-release features.

## Dependencies

WP-01-08, WP-07-04.

## Laravel Requirements

Implement only the server-side work directly required by this package.

## API Contract

Document every new or changed mobile/device contract.

## Flutter and SQLite Requirements

When affected, screens must read SQLite and repositories must synchronize server changes into SQLite.

## Permissions and Security

Apply least privilege, validation, authorization, rate limiting, and secure secret handling.

## Tests

Run targeted Pest, Flutter, SQLite migration, or integration tests appropriate to the changed layer.

## Documentation Updates

Update the relevant core or API document.

## Acceptance Criteria

- School profile is cached.
- UI uses local school name and branding.
- Maintenance and minimum-version states are handled.

## Definition of Done

- Scope is complete.
- Targeted tests pass.
- Static analysis passes.
- Contracts and migrations are documented.
- Final implementation report is provided.

## Implementation Notes

New feature `mobile/lib/features/school_bootstrap/`:

- `data/bootstrap_api.dart` — calls `GET /sync/bootstrap` (WP-01-08) and
  extracts only its `school` field (the `guardian`/`children`/
  `announcements`/`next_cursor` parts of that same response belong to
  WP-07-08/09/11, not this package). Reuses `ResolvedSchool.fromJson`
  from `school_setup` — the resolver and bootstrap `school` fields are the
  same shape server-side (`SchoolResolverResource` serializes both, per
  `docs/api/SYNC.md`).
- `data/bootstrap_repository.dart` — `syncSchoolProfile()` fetches and
  upserts the `school` portion straight into `school_profile`. This is the
  "repository writes the bootstrap response" half of this package's Scope
  line; `SchoolBindingGate` (WP-07-03) was already the "read from SQLite"
  half.
- Extracted `ResolvedSchool.toCompanion()` (was private, duplicated logic
  in `SchoolIdSetupController`) so both the initial-binding write path
  (WP-07-03) and this bootstrap-refresh write path share one mapping.

**Not wired to an automatic trigger**: `GET /sync/bootstrap` requires a
guardian's Sanctum token, and no login flow exists yet (WP-07-06). The
repository is complete and independently tested, but nothing in the app
calls `syncSchoolProfile()` yet — that's WP-07-06's job, right after a
successful login. Documented as an open item rather than inventing a
temporary/fake login just to wire a call site.

**"UI uses local school name and branding" / "Maintenance and
minimum-version states are handled"** — implemented as a school-status
gate wrapping every screen behind the binding, per
`docs/api/SCHOOL-RESOLVER.md`'s Client Responsibility section (previously
deferred out of WP-07-03's scope, since binding a school and *acting* on
its ongoing status are different concerns):

- `SchoolBindingGate` (`school_setup/presentation/`) now branches, once
  bound, through `_BoundSchoolGate`: `mobile_enabled` false or an
  installed version below `minimum_app_version` renders the new
  `SchoolStatusBlockedPage` (full block, nothing else usable);
  `maintenance_mode` is a non-blocking banner on `FoundationPage` instead —
  matching the doc's own distinct verbs ("block" vs. "show a notice" vs.
  "prompt an upgrade").
- `FoundationPage` now takes the cached `SchoolProfileData` directly:
  its AppBar shows the school's actual name (and logo, when set, via
  `Image.network` with a fallback icon) instead of the generic "Project
  LENS" placeholder title, and shows the maintenance banner when
  applicable. Existing tests keyed off its "Foundation Ready" body text
  are unaffected — only the branding around it changed.
- Added `package_info_plus` to read the installed app's actual version
  (`core/app_version_provider.dart`) — nothing already in the project
  could do this, and hand-maintaining a version constant in sync with
  `pubspec.yaml` would silently drift. `core/app_version.dart` is a small
  dotted-version comparator (`"1.2" == "1.2.0"`) matching the
  `X.Y.Z`-style strings this project uses; a version-lookup failure fails
  open (shows the app) rather than locking a guardian out over an
  unrelated plugin hiccup.

Tests: `app_version_test.dart` (comparator edge cases);
`bootstrap_repository_test.dart` (fetches and caches school data; a
repeated sync updates the row rather than duplicating it, mirroring
`SchoolProfileDao`'s uuid-keyed upsert from WP-07-02);
`school_binding_gate_test.dart` (`mobile_enabled` false blocks;
below-minimum version blocks; maintenance mode banners without blocking;
the normal case shows the school's name and content) — each overriding
`appVersionProvider` directly rather than depending on the real
`package_info_plus` platform channel, which has no test-time mock.

Verification: `flutter analyze` clean, `dart format` applied, `flutter
test` — 26/26 passing.
