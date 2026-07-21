<?php

use App\Actions\Attendance\ProcessRfidScan;
use App\Actions\RfidCards\AssignRfidCard;
use App\Enums\AttendanceEventType;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidScanClassification;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\School;
use App\Models\SchoolSettings;
use App\Models\Student;

function validScanFor(RfidDevice $device, Student $student, ?string $uid = null): RfidScan
{
    $uid ??= fake()->unique()->regexify('[A-F0-9]{8}');
    app(AssignRfidCard::class)($student, $uid);

    return RfidScan::factory()->for($device, 'device')->create([
        'uid' => $uid,
        'classification' => RfidScanClassification::Valid,
    ]);
}

test('a valid scan on an entry device creates an arrival event referencing the scan', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $scan = validScanFor($device, $student);

    $event = (new ProcessRfidScan)($scan);

    expect($event)->not->toBeNull();
    expect($event->rfid_scan_id)->toBe($scan->id);
    expect($event->student_id)->toBe($student->id);
    expect($event->event_type)->toBe(AttendanceEventType::Arrival);
});

test('a valid scan on an exit device creates a departure event', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Exit]);
    $student = Student::factory()->create();
    $scan = validScanFor($device, $student);

    $event = (new ProcessRfidScan)($scan);

    expect($event->event_type)->toBe(AttendanceEventType::Departure);
});

test('a valid scan on a bidirectional device is left unprocessed', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Both]);
    $student = Student::factory()->create();
    $scan = validScanFor($device, $student);

    $event = (new ProcessRfidScan)($scan);

    expect($event)->toBeNull();
    expect(AttendanceEvent::query()->count())->toBe(0);
});

test('a non-valid classified scan is not processed', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $scan = RfidScan::factory()->for($device, 'device')->create([
        'classification' => RfidScanClassification::UnknownCard,
    ]);

    $event = (new ProcessRfidScan)($scan);

    expect($event)->toBeNull();
});

test('processing the same scan twice does not create a duplicate event', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $scan = validScanFor($device, $student);

    $first = (new ProcessRfidScan)($scan);
    $second = (new ProcessRfidScan)($scan->fresh());

    expect($second->id)->toBe($first->id);
    expect(AttendanceEvent::query()->count())->toBe(1);
});

test('an arrival event does not clobber an existing departure on the same day, and vice versa', function () {
    $entryDevice = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $exitDevice = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Exit]);
    $student = Student::factory()->create();
    app(AssignRfidCard::class)($student, 'CARD0001');

    $arrivalScan = RfidScan::factory()->for($entryDevice, 'device')->create([
        'uid' => 'CARD0001',
        'classification' => RfidScanClassification::Valid,
    ]);
    $arrivalEvent = (new ProcessRfidScan)($arrivalScan);

    $departureScan = RfidScan::factory()->for($exitDevice, 'device')->create([
        'uid' => 'CARD0001',
        'classification' => RfidScanClassification::Valid,
    ]);
    $departureEvent = (new ProcessRfidScan)($departureScan);

    $summary = AttendanceDailySummary::query()->where('student_id', $student->id)->firstOrFail();
    expect($summary->arrival_event_id)->toBe($arrivalEvent->id);
    expect($summary->departure_event_id)->toBe($departureEvent->id);
});

test('the daily summary date is computed in the school\'s timezone, not UTC', function () {
    $school = School::factory()->create();
    SchoolSettings::factory()->for($school)->create(['timezone' => 'Asia/Manila']);

    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $uid = 'TZTEST01';
    app(AssignRfidCard::class)($student, $uid);

    // Create without firing the observer, so the automatic first processing
    // does not happen before created_at is deliberately backdated below.
    $scan = RfidScan::withoutEvents(function () use ($device, $uid) {
        $scan = RfidScan::factory()->for($device, 'device')->create([
            'uid' => $uid,
            'classification' => RfidScanClassification::Valid,
        ]);
        // 23:30 UTC is already 07:30 the next day in Asia/Manila (UTC+8).
        $scan->forceFill(['created_at' => '2026-07-21 23:30:00'])->save();

        return $scan->fresh();
    });

    $event = (new ProcessRfidScan)($scan);

    $summary = AttendanceDailySummary::query()->where('student_id', $student->id)->firstOrFail();
    expect($summary->date->toDateString())->toBe('2026-07-22');
    expect($event->occurred_at->toDateString())->toBe('2026-07-21');
});

test('creating a valid scan automatically triggers processing via the observer', function () {
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create();
    $uid = 'AUTO1234';
    app(AssignRfidCard::class)($student, $uid);

    $scan = RfidScan::factory()->for($device, 'device')->create([
        'uid' => $uid,
        'classification' => RfidScanClassification::Valid,
    ]);

    expect($scan->attendanceEvent)->not->toBeNull();
    expect($scan->attendanceEvent->student_id)->toBe($student->id);
});
