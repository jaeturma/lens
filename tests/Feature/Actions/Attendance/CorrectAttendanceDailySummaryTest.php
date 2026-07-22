<?php

use App\Actions\Attendance\CorrectAttendanceDailySummary;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\AuditLog;
use App\Models\RfidScan;
use App\Models\User;

test('correcting to absent clears a recorded arrival and departure', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create();
    $arrival = AttendanceEvent::factory()->create(['student_id' => $summary->student_id]);
    $departure = AttendanceEvent::factory()->create(['student_id' => $summary->student_id]);
    $summary->update(['arrival_event_id' => $arrival->id, 'departure_event_id' => $departure->id]);

    $corrected = app(CorrectAttendanceDailySummary::class)($summary, true, 'Card was tapped by another student in error.', $actor);

    expect($corrected->is_absent)->toBeTrue();
    expect($corrected->arrival_event_id)->toBeNull();
    expect($corrected->departure_event_id)->toBeNull();
});

test('correcting to present flips the flag without fabricating an arrival', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create(['is_absent' => true]);

    $corrected = app(CorrectAttendanceDailySummary::class)($summary, false, 'Nurse confirmed the student was on campus all day.', $actor);

    expect($corrected->is_absent)->toBeFalse();
    expect($corrected->arrival_event_id)->toBeNull();
});

test('a correction records an audit log with the reason and before/after state', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create(['is_absent' => false]);

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Parent called to report an absence.', $actor);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $actor->id,
        'action' => 'attendance_daily_summary.corrected',
        'target_type' => 'attendance_daily_summary',
        'target_id' => $summary->id,
    ]);

    $log = AuditLog::query()->where('target_id', $summary->id)->firstOrFail();
    expect($log->metadata['reason'])->toBe('Parent called to report an absence.');
    expect($log->metadata['before']['is_absent'])->toBeFalse();
    expect($log->metadata['after']['is_absent'])->toBeTrue();
});

test('a correction records a sync change for the daily summary', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create(['is_absent' => false]);

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Confirmed absent by homeroom teacher.', $actor);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'attendance_daily_summary',
        'resource_id' => $summary->id,
        'action' => 'updated',
    ]);
});

test('a correction never touches the underlying raw scan or attendance event rows', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create();
    $arrival = AttendanceEvent::factory()->create(['student_id' => $summary->student_id]);
    $summary->update(['arrival_event_id' => $arrival->id]);
    $scanId = $arrival->rfid_scan_id;

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Correcting a misattributed tap.', $actor);

    expect(RfidScan::query()->whereKey($scanId)->exists())->toBeTrue();
    expect(AttendanceEvent::query()->whereKey($arrival->id)->exists())->toBeTrue();
    expect(AttendanceEvent::query()->count())->toBe(1);
});
