<?php

use App\Actions\Attendance\CorrectAttendanceDailySummary;
use App\Actions\Attendance\MarkDailyAbsences;
use App\Actions\Attendance\ProcessRfidScan;
use App\Actions\RfidCards\AssignRfidCard;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\NotificationType;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidScanClassification;
use App\Enums\StudentStatus;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceRule;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\Student;

test('a valid arrival scan notifies the actively linked, opted-in guardian once', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $uid = 'ARRV0001';
    app(AssignRfidCard::class)($student, $uid);

    $scan = RfidScan::factory()->for($device, 'device')->create([
        'uid' => $uid,
        'classification' => RfidScanClassification::Valid,
    ]);

    $notification = GuardianNotification::query()->where('guardian_id', $guardian->id)->firstOrFail();
    expect($notification->type)->toBe(NotificationType::Arrival);
    expect(GuardianNotification::query()->count())->toBe(1);

    // Reprocessing the same scan (idempotent) must not duplicate it.
    (new ProcessRfidScan)($scan->fresh());
    expect(GuardianNotification::query()->count())->toBe(1);
});

test('a repeat entry-device tap the same day does not send a second arrival notification', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $uid = 'ARRV0002';
    app(AssignRfidCard::class)($student, $uid);

    RfidScan::factory()->for($device, 'device')->create(['uid' => $uid, 'classification' => RfidScanClassification::Valid]);
    RfidScan::factory()->for($device, 'device')->create(['uid' => $uid, 'classification' => RfidScanClassification::Valid]);

    expect(GuardianNotification::query()->where('type', NotificationType::Arrival)->count())->toBe(1);
});

test('a departure notifies the guardian, and each real departure tap notifies again', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Exit]);
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $uid = 'DEPT0001';
    app(AssignRfidCard::class)($student, $uid);

    RfidScan::factory()->for($device, 'device')->create(['uid' => $uid, 'classification' => RfidScanClassification::Valid]);
    RfidScan::factory()->for($device, 'device')->create(['uid' => $uid, 'classification' => RfidScanClassification::Valid]);

    expect(GuardianNotification::query()->where('type', NotificationType::Departure)->count())->toBe(2);
});

test('an arrival after the configured cutoff notifies as late, not arrival', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['arrival_cutoff_time' => '07:30:00']);
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $uid = 'LATE0001';
    app(AssignRfidCard::class)($student, $uid);

    $scan = RfidScan::withoutEvents(function () use ($device, $uid) {
        $scan = RfidScan::factory()->for($device, 'device')->create([
            'uid' => $uid,
            'classification' => RfidScanClassification::Valid,
        ]);
        $scan->forceFill(['created_at' => '2026-07-22 08:00:00'])->save();

        return $scan->fresh();
    });

    (new ProcessRfidScan)($scan);

    expect(GuardianNotification::query()->count())->toBe(1);
    expect(GuardianNotification::query()->firstOrFail()->type)->toBe(NotificationType::Late);
});

test('a guardian who opted out of attendance notifications receives none', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => false]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $uid = 'OPTOUT01';
    app(AssignRfidCard::class)($student, $uid);

    RfidScan::factory()->for($device, 'device')->create(['uid' => $uid, 'classification' => RfidScanClassification::Valid]);

    expect(GuardianNotification::query()->count())->toBe(0);
});

test('a guardian whose link is revoked receives no notification', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);
    $uid = 'REVOKED1';
    app(AssignRfidCard::class)($student, $uid);

    RfidScan::factory()->for($device, 'device')->create(['uid' => $uid, 'classification' => RfidScanClassification::Valid]);

    expect(GuardianNotification::query()->count())->toBe(0);
});

test('automatic absence marking notifies once, and re-running the sweep does not duplicate it', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    $student = Student::factory()->create(['status' => StudentStatus::Active]);
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $this->travelTo('2026-07-20 10:00:01');

    (new MarkDailyAbsences)();
    (new MarkDailyAbsences)();

    expect(GuardianNotification::query()->where('type', NotificationType::Absence)->count())->toBe(1);
});

test('a correction notifies once as a correction, not as an arrival or absence', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $summary = AttendanceDailySummary::factory()->for($student)->create(['is_absent' => false]);

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Confirmed absent by homeroom teacher.');

    expect(GuardianNotification::query()->count())->toBe(1);
    expect(GuardianNotification::query()->firstOrFail()->type)->toBe(NotificationType::Correction);
});

test('a no-op correction (same value re-applied) does not notify a second time', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $summary = AttendanceDailySummary::factory()->for($student)->create(['is_absent' => false]);

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Confirmed absent by homeroom teacher.');
    expect(GuardianNotification::query()->count())->toBe(1);

    app(CorrectAttendanceDailySummary::class)($summary->fresh(), true, 'Re-confirming, still absent.');

    expect(GuardianNotification::query()->count())->toBe(1);
});
