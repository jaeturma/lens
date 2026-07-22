# Google Play Release (WP-08-07)

Release configuration and process for the LENS parent mobile app. Scoped
to documenting release/environment commands without committing secrets —
no real keystore, Firebase project, or Play Console credentials exist in
this repository or development environment.

## Application Identity

- `applicationId` / package name: `com.lens.mobile`
  (`mobile/android/app/build.gradle.kts`). Unchanged from the Flutter
  scaffold default — no reason found to change it; this is the identity
  Play Console will register the app under and cannot be changed after
  first upload, so confirm it deliberately before the first real release.
- App display name: `Project LENS` (`AppConfig.appName`,
  `mobile/lib/core/config/app_config.dart`).

## Versioning

`mobile/pubspec.yaml`'s `version:` field is `MAJOR.MINOR.PATCH+BUILD`
(currently `0.1.0+1`) — `BUILD` becomes Android's `versionCode`,
`MAJOR.MINOR.PATCH` becomes `versionName`
(`mobile/android/app/build.gradle.kts`'s `defaultConfig` reads both via
`flutter.versionCode`/`flutter.versionName`, unchanged from the scaffold).

Policy for this project:

- Bump `PATCH` for a bug-fix-only release, `MINOR` for new
  guardian-facing functionality, `MAJOR` only for a breaking change to
  what a guardian can do (not expected pre-1.0).
- `+BUILD` (`versionCode`) must strictly increase on **every** Play
  Console upload, including two uploads with the same `MAJOR.MINOR.PATCH`
  (e.g. a resubmission after a rejected review) — Play Console rejects a
  non-increasing `versionCode` outright. Bump it even when the visible
  version number doesn't change.
- Either edit `pubspec.yaml` directly, or override at build time without
  touching the file:
  `flutter build appbundle --release --build-name=0.2.0 --build-number=5`.

## Release Signing

`mobile/android/app/build.gradle.kts`'s `release` build type reads
`mobile/android/key.properties` (gitignored — never commit it, see
`mobile/android/key.properties.example` for the exact keys required) when
present, and falls back to debug signing when it's absent — so a
checkout with no release secrets still builds
(`flutter build`/`flutter run --release`, this development environment,
CI). A debug-signed AAB is **not** valid for a real Play Console upload;
it exists only to prove the release build pipeline itself works.

To produce a real, uploadable release:

1. Generate a keystore once, kept **outside** this repository (a password
   manager or CI secret store):
   ```
   keytool -genkey -v -keystore lens-release.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias lens
   ```
2. Copy `mobile/android/key.properties.example` to
   `mobile/android/key.properties` and fill in `storeFile` (absolute path
   to the `.jks` above), `storePassword`, `keyAlias`, `keyPassword`.
3. Build (below) — the `release` build type now signs with it
   automatically.

Losing the release keystore permanently blocks future updates to the same
Play Console listing (Play requires the same signing key for every
update to an app) — back it up somewhere durable and outside this repo
before relying on it for a real submission.

## Build Commands

Real environment values (API base URL, Firebase options) are supplied via
`--dart-define` at build time, never committed — the same pattern
`docs/NOTIFICATIONS.md` already documents for the Flutter push
integration (WP-07-13) and `docs/api` generally uses for the Laravel side
(WP-08-08 owns actually provisioning a real Firebase project and
production API host; this package only documents how a build consumes
them once they exist):

```
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://api.example-school-lens.app/api/v1 \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=...
```

Output: `mobile/build/app/outputs/bundle/release/app-release.aab` — this
is the file uploaded to Play Console.

Omitting the `FIREBASE_*` defines is a supported, deliberate
configuration (`AppConfig.firebaseConfigured`, WP-07-13) — push
notifications are simply skipped; the app remains fully usable via
ordinary sync (`docs/OFFLINE-SYNC.md`). Omitting `API_BASE_URL` falls back
to the Android-emulator loopback default
(`http://10.0.2.2:8000/api/v1`) — never appropriate for a real release
build; always pass it explicitly.

A local `apk` build (`flutter build apk --release`, same `--dart-define`
flags) is useful for sideloaded testing before a Play Console upload but
is not itself submitted to the Store.

### Verified In This Environment

`flutter build appbundle --release` (no `--dart-define` flags, no
`key.properties` — proving only that the pipeline itself completes)
succeeded: `app-release.aab`, 56.9MB, debug-signed. Required one
environment-specific workaround, unrelated to app code or signing:
Kotlin's incremental compiler throws on Windows when a dependency (Pub
cache, this machine's `C:` drive) and the project (this repo, `D:`) sit on
different drive roots (`RelocatableFileToPathConverter`); disabled via
`kotlin.incremental=false` in `mobile/android/gradle.properties`. This
only affects build caching, not app behavior or output, and is safe to
keep regardless of environment.

## Icons

Still the unmodified Flutter scaffold launcher icon
(`mobile/android/app/src/main/res/mipmap-*/ic_launcher.png`) — no LENS
brand identity (logo, color, mark) has been supplied to this project.
**Not fixed here**: generating a placeholder logo isn't this package's
call to make unilaterally. Before a real Play Console submission:

1. Obtain a real LENS app icon (source artwork, ideally an SVG or
   1024×1024 PNG) from whoever owns the brand.
2. Generate the Android mipmap set from it — the `flutter_launcher_icons`
   package (not currently a dependency) is the standard way, or produce
   the mipmap-*/ic_launcher.png sizes manually.
3. Play Console also requires a separate 512×512 "hi-res icon" for the
   store listing itself (not bundled in the AAB) — same source artwork,
   different export.

## Screenshots

Not captured — Play Console requires actual Android phone/tablet
screenshots (minimum 2, JPEG/24-bit PNG, no alpha), and no Android
emulator or device is attached to this development machine (the same
limitation `docs/work-packages/phase-08/WP-08-01-...md` already
documented for manual binding verification). Before submission: run the
app on a real device or emulator with realistic seeded data (a bound
school, a guardian with linked children, some attendance history,
an announcement, a notification) and capture the home screen, attendance
history, announcements, and notifications screens at minimum.

## Data Safety Declaration (Play Console)

Derived from what the app actually collects/transmits/stores, per
`docs/api/SYNC.md` and `docs/SECURITY.md`'s baseline (re-confirmed during
WP-08-06's security review, nothing found beyond what's listed below):

| Data type | Collected? | Shared with third parties? | Purpose | Notes |
| --- | --- | --- | --- | --- |
| Name, email, phone number (guardian's own profile) | Yes | No | Account functionality, app functionality | Server-side only; never leaves the LENS installation the school operates. |
| Name, attendance records (linked children) | Yes | No | App functionality | Guardian's own linked, active students only (`docs/SECURITY.md` Roles and Permission Matrix; guardian isolation re-verified WP-08-06). |
| Device ID / push token | Yes | Yes — Google (Firebase Cloud Messaging), for delivery only | App functionality | `docs/NOTIFICATIONS.md`: the push signal itself carries no notification content, only a "go sync" hint. Revocable (`docs/SECURITY.md`: "push tokens can be revoked" — `DELETE /api/v1/notifications/device-tokens`). |
| App interactions / crash logs | Not currently collected | — | — | No analytics or crash-reporting SDK is present in `mobile/pubspec.yaml` as of this package. |

Data in transit: HTTPS only (the API base URL a real release build is
configured with, above, must be `https://`). Data at rest on-device:
`docs/SECURITY.md` — auth token in `flutter_secure_storage` only; the
synchronized dataset (guardian profile, linked children, attendance,
announcements, notifications) in the app's own SQLite database, excluded
from Android auto-backup (`docs/work-packages/phase-08/WP-08-01-...md`
re-verified this).

Users can request data deletion: **Yes**, via the process below — this
maps directly to Play Console's Data Safety form question of the same
name.

## Account and Data Deletion

Guardian accounts are provisioned by the school administrator, not
self-registered (`docs/SECURITY.md` Roles and Permission Matrix) — there
is deliberately no in-app "delete my account" action, and no public
self-service signup to delete a self-created account from in the first
place. The process:

1. **Immediate access revocation**: a school administrator deactivates
   the guardian's account (existing admin capability, WP-02-05). Every
   currently-authenticated session is rejected on its very next request,
   not just future logins (`App\Http\Middleware\EnsureGuardianAccountIsActive`,
   WP-08-03) — this is the fast path for "I no longer want this app to
   have my data going forward."
2. **Full data erasure on request**: a guardian (or the school on their
   behalf) contacts the school administrator to request permanent
   deletion of their guardian profile and associated account. This is a
   manual/administrative process in this release, not an automated
   endpoint — deliberate, since attendance and RFID-derived records are
   the school's own operational/audit records
   (`docs/SECURITY.md` Audit Logging), not solely the guardian's to erase
   unilaterally, and a real deletion decision needs the school's
   involvement regardless.

This "request via the organization that provisioned the account" model is
an accepted pattern for Play Console's account-deletion requirement when
an app's accounts are provisioned by an organization rather than
self-registered — the actual contact path (a specific email/phone/URL)
is school-specific and must be filled in per deployment, not hardcoded
here.

## Privacy Policy

Required by Play Console before submission — no policy is hosted yet.
Before submission: publish a privacy policy page (a static page is
sufficient; no specific hosting is mandated by this package) covering, at
minimum, everything in the Data Safety table above, and the account/data
deletion process above, then provide its URL in Play Console's App
content → Privacy policy field. This package does not fabricate a
placeholder URL — an unpublished/fake privacy policy link would fail Play
Console review regardless.

## Store Listing Checklist

Pending items are explicitly marked; nothing here is fabricated content.

- [ ] App icon (512×512 hi-res + in-app launcher set) — blocked on real
  brand assets, see Icons above.
- [ ] At least 2 phone screenshots — blocked on device/emulator access,
  see Screenshots above.
- [ ] Short description (≤80 characters)
- [ ] Full description (≤4000 characters)
- [ ] App category (Education, most likely fit)
- [ ] Contact email (support/inquiries)
- [ ] Privacy policy URL — blocked, see Privacy Policy above
- [ ] Content rating questionnaire (Play Console's own IARC flow — no
  outside deliverable to produce; the answers depend on final app
  behavior, complete this once the release build is otherwise final)
- [ ] Data Safety form — content ready, see the table above; enter it
  into Play Console's own form (not a file this repo produces)
- [ ] Target audience / Families policy declaration — the app is for
  parents/guardians, not children directly, but school-context apps
  often draw extra Play Console scrutiny here; confirm the correct
  declaration during submission rather than assuming
- [x] `applicationId` confirmed (`com.lens.mobile`)
- [x] Versioning scheme documented and working (`0.1.0+1` builds cleanly)
- [x] Release signing mechanism in place (key.properties-based, no
  secrets committed)
- [x] Release AAB build command documented and verified to produce a
  valid bundle in this environment
