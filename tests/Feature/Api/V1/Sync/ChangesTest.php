<?php

use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\School;
use App\Models\User;
use App\Support\Sync\SyncCursor;

function syncChangesUri(string $cursor, ?int $limit = null): string
{
    $query = array_filter(['cursor' => $cursor, 'limit' => $limit], fn ($value) => $value !== null);

    return '/api/v1/sync/changes?'.http_build_query($query);
}

test('incremental sync returns changes after the given cursor', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Updated, ['name' => 'New Name']);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial()));

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'has_more' => false,
            'changes' => [
                [
                    'resource_type' => $school->getMorphClass(),
                    'resource_id' => $school->id,
                    'action' => 'updated',
                    'payload' => ['name' => 'New Name'],
                ],
            ],
        ],
    ]);

    expect($response->json('data.next_cursor'))->toBe((string) SyncCursor::fromSequence($change->id));
});

test('a cursor at the current tip returns no changes and leaves the cursor unchanged', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Created);
    $cursor = SyncCursor::fromSequence($change->id);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursor));

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => ['has_more' => false, 'changes' => []],
    ]);
    expect($response->json('data.next_cursor'))->toBe((string) $cursor);
});

test('a request without a cursor is rejected', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/changes');

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('a malformed cursor is rejected', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson(syncChangesUri('not-a-cursor'));

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('a limit beyond 200 is rejected', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial(), 201));

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('results are chunked by limit and report has_more', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $school = School::factory()->create();
    for ($i = 0; $i < 3; $i++) {
        (new RecordSyncChange)($school, SyncChangeAction::Updated);
    }

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial(), 2));

    $response->assertOk()->assertJson(['data' => ['has_more' => true]]);
    expect($response->json('data.changes'))->toHaveCount(2);
});

test('a non-guardian account is rejected from incremental sync', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial()));

    $response->assertStatus(403)->assertJson(['success' => false]);
});
