<?php

namespace App\Actions\Audit;

use App\Models\AuditLog;
use App\Models\User;
use App\Support\RedactsSensitiveMetadata;
use Illuminate\Database\Eloquent\Model;

class RecordAuditLog
{
    use RedactsSensitiveMetadata;

    /**
     * @param  array<string, mixed>  $metadata
     */
    public function __invoke(?User $actor, string $action, ?Model $target = null, array $metadata = []): AuditLog
    {
        return AuditLog::create([
            'actor_id' => $actor?->id,
            'action' => $action,
            'target_type' => $target?->getMorphClass(),
            'target_id' => $target?->getKey(),
            'metadata' => $this->redact($metadata),
        ]);
    }
}
