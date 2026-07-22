<?php

use App\Actions\Attendance\MarkDailyAbsences;
use App\Actions\RfidCards\AssignRfidCard;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidScanClassification;
use App\Enums\StudentStatus;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceRule;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\Student;

// 2026-07-20 is a Monday (matches AttendanceRuleFactory's default
// operating_days of Monday-Friday); 2026-07-19 is the preceding Sunday.

test('an active student with no arrival is marked absent after the cutoff on an operating day', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    $student = Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-20 10:00:01');

    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(1);

    $summary = AttendanceDailySummary::query()->where('student_id', $student->id)->firstOrFail();
    expect($summary->is_absent)->toBeTrue();
    expect($summary->arrival_event_id)->toBeNull();
});

test('nothing is marked before the configured cutoff', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-20 09:59:59');

    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(0);
    expect(AttendanceDailySummary::query()->count())->toBe(0);
});

test('nothing is marked on a non-operating day even after the cutoff time', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-19 10:00:01');

    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(0);
    expect(AttendanceDailySummary::query()->count())->toBe(0);
});

test('a student who already arrived is excluded and remains present', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $student = Student::factory()->create(['status' => StudentStatus::Active]);
    $uid = 'PRESENT1';
    app(AssignRfidCard::class)($student, $uid);

    $this->travelTo('2026-07-20 07:00:00');
    RfidScan::factory()->for($device, 'device')->create([
        'uid' => $uid,
        'classification' => RfidScanClassification::Valid,
    ]);

    $this->travelTo('2026-07-20 10:00:01');
    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(0);

    $summary = AttendanceDailySummary::query()->where('student_id', $student->id)->firstOrFail();
    expect($summary->is_absent)->toBeFalse();
    expect($summary->arrival_event_id)->not->toBeNull();
});

test('an inactive student is never marked absent', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    Student::factory()->create(['status' => StudentStatus::Inactive]);

    $this->travelTo('2026-07-20 10:00:01');

    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(0);
    expect(AttendanceDailySummary::query()->count())->toBe(0);
});

test('running the action again the same day does not re-mark or duplicate the summary', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-20 10:00:01');

    $first = (new MarkDailyAbsences)();
    $second = (new MarkDailyAbsences)();

    expect($first)->toBe(1);
    expect($second)->toBe(0);
    expect(AttendanceDailySummary::query()->count())->toBe(1);
});

test('nothing is marked when no attendance rule is configured', function () {
    bindSchool(['timezone' => 'UTC']);
    Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-20 12:00:00');

    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(0);
    expect(AttendanceDailySummary::query()->count())->toBe(0);
});

test('nothing is marked when no school is configured', function () {
    Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-20 12:00:00');

    $marked = (new MarkDailyAbsences)();

    expect($marked)->toBe(0);
    expect(AttendanceDailySummary::query()->count())->toBe(0);
});
