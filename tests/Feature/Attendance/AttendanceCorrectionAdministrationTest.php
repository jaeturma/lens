<?php

use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\User;

test('a guardian is rejected from correcting a daily summary', function () {
    $guardian = User::factory()->create();
    $summary = AttendanceDailySummary::factory()->create();

    $this->actingAs($guardian)
        ->patch(route('attendance.daily-summaries.correct', $summary), [
            'is_absent' => true,
            'reason' => 'Attempting an unauthorized correction.',
        ])
        ->assertForbidden();
});

test('an administrator can correct a daily summary to absent, clearing recorded events', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create();
    $arrival = AttendanceEvent::factory()->create(['student_id' => $summary->student_id]);
    $summary->update(['arrival_event_id' => $arrival->id]);

    $response = $this->actingAs($admin)->patch(route('attendance.daily-summaries.correct', $summary), [
        'is_absent' => true,
        'reason' => 'Confirmed absent by homeroom teacher.',
    ]);

    $response->assertRedirect();

    $fresh = $summary->fresh();
    expect($fresh->is_absent)->toBeTrue();
    expect($fresh->arrival_event_id)->toBeNull();
});

test('a correction requires a reason', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create();

    $response = $this->actingAs($admin)->patch(route('attendance.daily-summaries.correct', $summary), [
        'is_absent' => true,
    ]);

    $response->assertSessionHasErrors('reason');
    expect($summary->fresh()->is_absent)->toBeFalse();
});

test('a correction requires is_absent', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $summary = AttendanceDailySummary::factory()->create();

    $response = $this->actingAs($admin)->patch(route('attendance.daily-summaries.correct', $summary), [
        'reason' => 'Missing the is_absent field entirely.',
    ]);

    $response->assertSessionHasErrors('is_absent');
});
