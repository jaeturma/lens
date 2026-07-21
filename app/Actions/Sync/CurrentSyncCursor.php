<?php

namespace App\Actions\Sync;

use App\Models\SyncChange;
use App\Support\Sync\SyncCursor;

class CurrentSyncCursor
{
    public function __invoke(): SyncCursor
    {
        return SyncCursor::fromSequence((int) (SyncChange::query()->max('id') ?? 0));
    }
}
