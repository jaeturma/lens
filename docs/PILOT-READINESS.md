# Pilot Readiness Checklist (WP-08-09)

Go/no-go checklist for onboarding **one** participating school to a LENS
pilot — synthesizes verification performed across WP-08-01 through
WP-08-08 (and the phase 1–7 work each of those validated), not a
re-verification from scratch. Each item below is either checked (already
built and verified, no further engineering work needed) or unchecked
(a required action before go-live, with the exact procedure or an
explicit blocker — nothing here is a vague TODO).

## 1. School Setup

- [ ] Create the school's `School` + `SchoolSettings` row.
- [ ] Create the initial System Administrator account.

**Known limitation** (this package's own finding): no admin UI exists for
either — every pilot school's onboarding requires this one-time manual
step via `php artisan tinker`:

```php
$school = \App\Models\School::create([
    'public_id' => 'SCH-XXXX', // the school's real, unique public School ID
    'name' => 'Real School Name',
    'logo_url' => null,
]);

// via the `settings()` relation, not `SchoolSettings::create([...])`
// directly — `school_id` is deliberately not in SchoolSettings's own
// Fillable list (`app/Models/SchoolSettings.php`), so setting it must go
// through the relationship.
$school->settings()->create([
    'timezone' => 'Asia/Manila', // the real school's timezone
    'mobile_enabled' => true,
    'maintenance_mode' => false,
    'maintenance_message' => null,
    'notifications_enabled' => true,
    'minimum_app_version' => '0.1.0',
]);

\App\Models\User::factory()->systemAdministrator()->create([
    'name' => 'Real Admin Name',
    'email' => 'admin@realschool.example',
    'password' => \Illuminate\Support\Facades\Hash::make('a-real-strong-password'),
]);
```

`database/seeders/DatabaseSeeder.php` seeds only a fixed dummy
`test@example.com` administrator — fine for development, **not** for a
real pilot; replace it with the above before go-live.

## 2. Attendance Rules

- [ ] Create the school's `AttendanceRule` row — also tinker-only, no
  admin UI exists yet:

```php
\App\Models\AttendanceRule::create([
    'school_id' => $school->id,
    'operating_days' => [1, 2, 3, 4, 5], // ISO weekdays, Mon-Fri
    'arrival_cutoff_time' => '07:30:00',
    'departure_time' => '16:00:00',
    'absence_cutoff_time' => '10:00:00',
    'duplicate_window_seconds' => 5,
]);
```

Confirm every value matches the real school's actual schedule before
go-live — a wrong `arrival_cutoff_time`/`absence_cutoff_time` directly
mis-marks students late or absent from day one.

## 3. Accounts

- [x] School/System Administrator management — built, tested
  (`tests/Feature/Guardians/GuardianAdministrationTest.php`,
  `tests/Feature/Students/StudentAdministrationTest.php`).
- [x] Guardian account creation and activation/deactivation — built and
  tested; deactivation now revokes an already-issued mobile session on
  its very next request, not just future logins
  (`App\Http\Middleware\EnsureGuardianAccountIsActive`, WP-08-03).
- [ ] Real guardian accounts (name, email, password) must be created by
  the school administrator before any pilot guardian can log in — no
  guardian self-registration exists, by design
  (`docs/SECURITY.md` Roles and Permission Matrix).
- [ ] Each pilot guardian must be given their login email and an initial
  password through a secure channel — an operational step for the school
  to own, not something this codebase automates or should.

## 4. RFID Cards and Devices

- [x] Device registration/activation/revocation — built and tested
  (`tests/Feature/RfidDevices/RfidDeviceAdministrationTest.php`).
- [x] Card assignment/deactivation/replacement — built and tested
  (`tests/Feature/RfidCards/RfidCardAdministrationTest.php`).
- [x] Duplicate/idempotency protection at concurrent, practical-pilot
  scale — hardened WP-08-04 (unique `(rfid_device_id, request_id)`
  index; the previous check-then-act race is now closed at the database
  level, not just the application level).
- [ ] Each physical RFID reader must be registered
  (`device_code` + generated secret, `docs/api/RFID.md`) and have that
  secret configured into the physical device before go-live — a one-time
  per-device manual step; the secret is shown exactly once at
  registration and cannot be retrieved again.
- [ ] Each pilot student's physical card must be assigned
  (`AssignRfidCard`) before their attendance can be captured.

## 5. Sync (Mobile)

- [x] Offline-first sync engine — cursor safety, pagination, interrupted
  sync resuming without skipping or duplicating changes (WP-07-08,
  re-verified end-to-end WP-08-02).
- [x] Offline reads for home, attendance history, announcements, and
  notifications — all render from SQLite regardless of connectivity.
- [x] Missed-push recovery — a notification never delivered by push (no
  Firebase configured, delivery failure, device offline at send time)
  still reaches the guardian through the ordinary startup sync, verified
  end-to-end with zero push involvement (WP-08-05).
- [ ] The manual, real-device verification checklist
  (`docs/work-packages/phase-08/WP-08-01-...md` Manual Device
  Verification Checklist — fresh install, force-stop/relaunch, Android
  backup/restore behavior, clear-storage behavior) remains **unexecuted**
  on a real Android device or emulator — none is attached to any
  development environment this phase's work had access to. Required
  before go-live; cannot be substituted with the automated test suite
  alone (that suite already covers the equivalent logic at the Dart
  level — this checklist item is specifically about real Android process
  lifecycle and OS-level backup behavior, which only a real device
  exercises).

## 6. Privacy

- [x] Data Safety declaration content drafted, derived from what the app
  actually collects/transmits (`docs/RELEASE.md` Data Safety
  Declaration, cross-checked against WP-08-06's security review).
- [x] Account/data deletion process documented — deactivation is
  immediate (WP-08-03); full erasure is a request-to-administrator
  process, deliberately not a self-service in-app action, since guardian
  accounts are administrator-provisioned and attendance/RFID records are
  the school's own operational records (`docs/RELEASE.md` Account and
  Data Deletion).
- [ ] No privacy policy page is hosted anywhere yet — blocks Play Store
  submission specifically (`docs/RELEASE.md` Privacy Policy). Does
  **not** block a private pilot distributed outside the Play Store (see
  Go/No-Go below).

## 7. Support

- [ ] No pilot support process or contact exists yet in this repository —
  this is an operational decision between the pilot school and whoever
  operates the deployment, not something this codebase can supply on its
  own. **Recommended minimum before go-live**: a named technical contact
  and an agreed expected response time for the pilot's duration, and a
  plain-language explanation for school staff of what "sync," "offline,"
  and "missed a push notification but it showed up later" mean in
  practice (this phase's own findings, WP-08-02/08-05) — parents will ask.

## 8. Backup

- [x] Backup and rollback procedure documented, including the concrete
  `mysqldump` command and the distinction between a bad deploy, a bad
  migration, and already-destroyed data (`docs/DEPLOYMENT.md` Backup +
  Rollback, WP-08-08).
- [ ] No backup has actually been taken or restore-tested yet — no real
  production database exists in any environment this phase's work had
  access to. **Required before go-live**: take one backup against the
  real production database once provisioned, and dry-run the restore
  procedure at least once, before real attendance data starts
  accumulating.

## 9. Known Limitations (Explicit)

Carried over from the sections above, gathered here per this package's
own acceptance criterion:

- No admin UI for initial school/attendance-rule setup — `tinker` only
  (Sections 1–2).
- No guardian self-registration, by design (Section 3).
- No in-app self-service account/data deletion, by design (Section 6).
- No real-device verification performed — no Android device/emulator
  available in this development environment (Section 5).
- No app icon/brand assets — still the unmodified Flutter scaffold icon
  (`docs/RELEASE.md` Icons).
- No screenshots captured for a Play Store listing (`docs/RELEASE.md`
  Screenshots).
- No real Firebase project or credentials provisioned anywhere — push
  notifications are inert (never sent, never crash anything) until one
  is; ordinary sync still delivers everything regardless
  (`docs/NOTIFICATIONS.md`, `docs/RELEASE.md`).
- No real release-signing keystore — the release AAB build pipeline is
  verified working, but only debug-signed (`docs/RELEASE.md`).
- `GET /api/v1/health` is liveness-only — it does not check database or
  queue connectivity (`docs/DEPLOYMENT.md` Health Check).
- Single queue-worker process assumed sufficient — sized for pilot scale
  per WP-08-04's own throughput findings (~300 req/sec measured at the
  full HTTP-scan-ingestion level, far above any realistic single-school
  tap rate), not load-tested against real push-delivery volume at any
  larger scale.

## Go/No-Go Criteria

**Go**, once all of the following hold for the specific pilot school:

1. School, `SchoolSettings`, and `AttendanceRule` created and confirmed
   correct for that school's real schedule (Sections 1–2).
2. At least one real System/School Administrator account exists with a
   real, securely-set password (Section 3).
3. Physical RFID devices are registered and cards are assigned for at
   least the pilot's participating students (Section 4).
4. The manual device verification checklist (Section 5) has been run
   once on a real Android device.
5. A named support contact has been agreed with the school (Section 7).
6. A backup has been taken at least once against the real production
   database and its restore procedure dry-run tested (Section 8).

**No-Go** if any of the above is incomplete, or if:

- The pilot's own expectations require push notifications but no
  Firebase project is configured — mitigated in practice (sync still
  delivers every notification, WP-08-05), but guardians will not get a
  real-time alert, which may not meet the pilot's actual promise to
  parents.
- Distribution is meant to go through the Play Store specifically and no
  privacy policy is hosted yet (`docs/RELEASE.md`) — this blocks Play
  Store review outright.

A **private pilot** — an APK sideloaded directly to a small guardian
group, entirely outside the Play Store — can proceed without the Play
Store-specific items (app icon, screenshots, hosted privacy policy,
production-signed release build): those block a *public Play Store
listing* specifically, not the underlying app's readiness for real
guardians at a real school to actually use it. Distributing through Play
Console's own internal/closed testing tracks instead of a fully public
listing may still require some of these (Google's own testing-track
policy requirements are not re-verified here and can change) — confirm
directly against current Play Console policy before assuming that path
avoids them, rather than treating it as equivalent to sideloading.
