<?php

use App\Enums\SyncChangeAction;
use App\Models\Guardian;
use App\Models\SyncChange;

test('creating a guardian records a sync change with a full snapshot payload', function () {
    $guardian = Guardian::factory()->create();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian',
        'resource_id' => $guardian->id,
        'action' => SyncChangeAction::Created->value,
    ]);

    $change = SyncChange::query()->latest('id')->first();

    expect($change->payload)->toMatchArray([
        'uuid' => $guardian->uuid,
        'name' => $guardian->name,
        'email' => $guardian->email,
        'mobile_number' => $guardian->mobile_number,
        'status' => 'active',
    ]);
});

test('updating a guardian records a sync change reflecting the new state', function () {
    $guardian = Guardian::factory()->create();

    $guardian->update(['mobile_number' => '09171234567']);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian',
        'resource_id' => $guardian->id,
        'action' => SyncChangeAction::Updated->value,
    ]);

    $latest = SyncChange::query()->latest('id')->first();

    expect($latest->payload['mobile_number'])->toBe('09171234567');
});

test('deleting a guardian records a sync change', function () {
    $guardian = Guardian::factory()->create();

    $guardian->delete();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian',
        'resource_id' => $guardian->id,
        'action' => SyncChangeAction::Deleted->value,
    ]);
});
