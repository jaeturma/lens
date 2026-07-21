<?php

use App\Enums\GuardianStudentLinkStatus;
use App\Enums\SyncChangeAction;
use App\Models\GuardianStudentLink;
use App\Models\SyncChange;

test('creating a link records a sync change with a full snapshot payload', function () {
    $link = GuardianStudentLink::factory()->create();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian_student_link',
        'resource_id' => $link->id,
        'action' => SyncChangeAction::Created->value,
    ]);

    $change = SyncChange::query()->latest('id')->first();

    expect($change->payload)->toMatchArray([
        'uuid' => $link->uuid,
        'student_id' => $link->student_id,
        'guardian_id' => $link->guardian_id,
        'status' => 'active',
    ]);
});

test('updating a non-status field records an Updated sync change', function () {
    $link = GuardianStudentLink::factory()->create();

    $link->update(['is_primary_contact' => true]);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian_student_link',
        'resource_id' => $link->id,
        'action' => SyncChangeAction::Updated->value,
    ]);
});

test('revoking a link records a Revoked sync change', function () {
    $link = GuardianStudentLink::factory()->create();

    $link->update(['status' => GuardianStudentLinkStatus::Revoked]);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian_student_link',
        'resource_id' => $link->id,
        'action' => SyncChangeAction::Revoked->value,
    ]);

    $latest = SyncChange::query()->latest('id')->first();
    expect($latest->payload['status'])->toBe('revoked');
});

test('deleting a link records a sync change', function () {
    $link = GuardianStudentLink::factory()->create();

    $link->delete();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian_student_link',
        'resource_id' => $link->id,
        'action' => SyncChangeAction::Deleted->value,
    ]);
});
