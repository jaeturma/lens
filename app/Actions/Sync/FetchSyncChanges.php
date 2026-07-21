<?php

namespace App\Actions\Sync;

use App\Models\SyncChange;
use App\Support\Sync\SyncChangePage;
use App\Support\Sync\SyncCursor;

class FetchSyncChanges
{
    private const MAX_LIMIT = 200;

    public function __invoke(SyncCursor $cursor, int $limit = 100): SyncChangePage
    {
        $limit = max(1, min($limit, self::MAX_LIMIT));

        $changes = SyncChange::query()
            ->where('id', '>', $cursor->sequence())
            ->orderBy('id')
            ->limit($limit + 1)
            ->get();

        $hasMore = $changes->count() > $limit;
        $page = $changes->take($limit)->values();

        $nextCursor = $page->isNotEmpty()
            ? SyncCursor::fromSequence((int) $page->last()->id)
            : $cursor;

        return new SyncChangePage($page, $nextCursor, $hasMore);
    }
}
