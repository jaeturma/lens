<?php

use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\School;
use App\Models\SyncChange;

test('it records the resource, action, and payload', function () {
    $school = School::factory()->create();

    $change = (new RecordSyncChange)($school, SyncChangeAction::Updated, ['name' => 'New Name']);

    expect($change)->toBeInstanceOf(SyncChange::class)
        ->and($change->resource_type)->toBe($school->getMorphClass())
        ->and($change->resource_id)->toBe($school->id)
        ->and($change->action)->toBe(SyncChangeAction::Updated)
        ->and($change->payload)->toBe(['name' => 'New Name'])
        ->and($change->created_at)->not->toBeNull();
});

test('a deleted/revoked/expired change row is its own tombstone', function () {
    $school = School::factory()->create();
    $schoolId = $school->id;
    $school->delete();

    $change = (new RecordSyncChange)($school, SyncChangeAction::Deleted);

    expect($change->resource_id)->toBe($schoolId)
        ->and($change->action)->toBe(SyncChangeAction::Deleted);

    $this->assertDatabaseHas('sync_changes', [
        'id' => $change->id,
        'resource_id' => $schoolId,
        'action' => 'deleted',
    ]);
});

test('it redacts secret-shaped payload keys at any nesting depth', function () {
    $school = School::factory()->create();

    $change = (new RecordSyncChange)($school, SyncChangeAction::Updated, [
        'token' => 'abc123',
        'nested' => ['secret' => 'shh', 'note' => 'kept'],
    ]);

    expect($change->payload)->toBe([
        'token' => '[redacted]',
        'nested' => ['secret' => '[redacted]', 'note' => 'kept'],
    ]);
});
