<?php

use App\Actions\Sync\FetchSyncChanges;
use App\Models\SyncChange;
use App\Support\Sync\SyncCursor;

test('it pages through changes in order, chunked by limit', function () {
    $changes = SyncChange::factory()->count(5)->create();
    $ids = $changes->pluck('id')->values();

    $page1 = (new FetchSyncChanges)(SyncCursor::initial(), limit: 2);

    expect($page1->changes->pluck('id')->all())->toBe($ids->take(2)->all())
        ->and($page1->hasMore)->toBeTrue()
        ->and($page1->nextCursor->sequence())->toBe($ids[1]);

    $page2 = (new FetchSyncChanges)($page1->nextCursor, limit: 2);

    expect($page2->changes->pluck('id')->all())->toBe($ids->slice(2, 2)->values()->all())
        ->and($page2->hasMore)->toBeTrue()
        ->and($page2->nextCursor->sequence())->toBe($ids[3]);

    $page3 = (new FetchSyncChanges)($page2->nextCursor, limit: 2);

    expect($page3->changes->pluck('id')->all())->toBe($ids->slice(4, 1)->values()->all())
        ->and($page3->hasMore)->toBeFalse()
        ->and($page3->nextCursor->sequence())->toBe($ids[4]);
});

test('a cursor with no new changes returns an empty, deterministic page', function () {
    $changes = SyncChange::factory()->count(2)->create();
    $lastId = $changes->last()->id;
    $cursor = SyncCursor::fromSequence($lastId);

    $page = (new FetchSyncChanges)($cursor);

    expect($page->changes)->toBeEmpty()
        ->and($page->hasMore)->toBeFalse()
        ->and($page->nextCursor->sequence())->toBe($lastId);
});

test('a non-positive limit is clamped to at least one result per page', function () {
    SyncChange::factory()->count(2)->create();

    $page = (new FetchSyncChanges)(SyncCursor::initial(), limit: 0);

    expect($page->changes)->toHaveCount(1);
});
