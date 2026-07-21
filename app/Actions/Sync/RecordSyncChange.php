<?php

namespace App\Actions\Sync;

use App\Enums\SyncChangeAction;
use App\Models\SyncChange;
use App\Support\RedactsSensitiveMetadata;
use Illuminate\Database\Eloquent\Model;

class RecordSyncChange
{
    use RedactsSensitiveMetadata;

    /**
     * @param  array<string, mixed>  $payload
     */
    public function __invoke(Model $resource, SyncChangeAction $action, array $payload = []): SyncChange
    {
        return SyncChange::create([
            'resource_type' => $resource->getMorphClass(),
            'resource_id' => $resource->getKey(),
            'action' => $action,
            'payload' => $this->redact($payload),
        ]);
    }
}
