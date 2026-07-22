<?php

use App\Actions\Attendance\CorrectAttendanceDailySummary;
use App\Enums\SyncChangeAction;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\SyncChange;

test('creating a daily summary records a sync change', function () {
    $summary = AttendanceDailySummary::factory()->create();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'attendance_daily_summary',
        'resource_id' => $summary->id,
        'action' => SyncChangeAction::Created->value,
    ]);
});

test('updating a daily summary records a sync change with the current arrival/departure state', function () {
    $summary = AttendanceDailySummary::factory()->create();
    $arrival = AttendanceEvent::factory()->create(['student_id' => $summary->student_id]);

    $summary->update(['arrival_event_id' => $arrival->id]);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'attendance_daily_summary',
        'resource_id' => $summary->id,
        'action' => SyncChangeAction::Updated->value,
    ]);
});

test('the sync change payload carries is_late and is_absent', function () {
    $summary = AttendanceDailySummary::factory()->create();
    $arrival = AttendanceEvent::factory()->create(['student_id' => $summary->student_id, 'is_late' => true]);

    $summary->update(['arrival_event_id' => $arrival->id, 'is_absent' => false]);

    $change = SyncChange::query()
        ->where('resource_type', 'attendance_daily_summary')
        ->where('resource_id', $summary->id)
        ->latest('id')
        ->firstOrFail();

    expect($change->payload['is_late'])->toBeTrue();
    expect($change->payload['is_absent'])->toBeFalse();
});

test('an update made through CorrectAttendanceDailySummary is recorded as corrected, not a plain update', function () {
    $summary = AttendanceDailySummary::factory()->create(['is_absent' => false]);

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Confirmed absent by homeroom teacher.');

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'attendance_daily_summary',
        'resource_id' => $summary->id,
        'action' => SyncChangeAction::Corrected->value,
    ]);
});

test('an ordinary update after a correction goes back to being recorded as updated', function () {
    $summary = AttendanceDailySummary::factory()->create(['is_absent' => false]);

    app(CorrectAttendanceDailySummary::class)($summary, true, 'Confirmed absent by homeroom teacher.');
    $summary->update(['is_absent' => false]);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'attendance_daily_summary',
        'resource_id' => $summary->id,
        'action' => SyncChangeAction::Updated->value,
    ]);
});
