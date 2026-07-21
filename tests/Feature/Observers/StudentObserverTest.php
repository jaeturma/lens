<?php

use App\Enums\SyncChangeAction;
use App\Models\Student;
use App\Models\SyncChange;

test('creating a student records a sync change with a full snapshot payload', function () {
    $student = Student::factory()->create();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'student',
        'resource_id' => $student->id,
        'action' => SyncChangeAction::Created->value,
    ]);

    $change = SyncChange::query()->latest('id')->first();

    expect($change->payload)->toMatchArray([
        'uuid' => $student->uuid,
        'lrn' => $student->lrn,
        'student_number' => $student->student_number,
        'name' => $student->name,
        'status' => 'active',
    ]);
});

test('updating a student records a sync change reflecting the new state', function () {
    $student = Student::factory()->create();

    $student->update(['name' => 'Updated Name']);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'student',
        'resource_id' => $student->id,
        'action' => SyncChangeAction::Updated->value,
    ]);

    $latest = SyncChange::query()->latest('id')->first();

    expect($latest->payload['name'])->toBe('Updated Name');
});

test('deleting a student records a sync change', function () {
    $student = Student::factory()->create();

    $student->delete();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'student',
        'resource_id' => $student->id,
        'action' => SyncChangeAction::Deleted->value,
    ]);
});
