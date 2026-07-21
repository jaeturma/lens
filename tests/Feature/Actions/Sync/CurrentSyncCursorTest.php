<?php

use App\Actions\Sync\CurrentSyncCursor;
use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\School;

test('it returns the initial cursor when there are no changes yet', function () {
    expect((new CurrentSyncCursor)()->sequence())->toBe(0);
});

test('it returns the sequence of the most recent change', function () {
    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Created);

    expect((new CurrentSyncCursor)()->sequence())->toBe($change->id);
});
