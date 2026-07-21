<?php

namespace App\Support\Sync;

use App\Models\SyncChange;
use Illuminate\Support\Collection;

final class SyncChangePage
{
    /**
     * @param  Collection<int, SyncChange>  $changes
     */
    public function __construct(
        public readonly Collection $changes,
        public readonly SyncCursor $nextCursor,
        public readonly bool $hasMore,
    ) {}
}
