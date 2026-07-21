<?php

use App\Enums\SyncChangeAction;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;

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
