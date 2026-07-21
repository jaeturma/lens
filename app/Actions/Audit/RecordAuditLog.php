<?php

namespace App\Actions\Audit;

use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class RecordAuditLog
{
    /**
     * Metadata keys redacted before storage, regardless of nesting depth.
     *
     * @var list<string>
     */
    private const REDACTED_KEYS = [
        'password',
        'password_confirmation',
        'token',
        'secret',
        'two_factor_secret',
        'two_factor_recovery_codes',
        'remember_token',
    ];

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

    /**
     * @param  array<string, mixed>  $metadata
     * @return array<string, mixed>
     */
    private function redact(array $metadata): array
    {
        foreach ($metadata as $key => $value) {
            if (is_array($value)) {
                $metadata[$key] = $this->redact($value);

                continue;
            }

            if (in_array(strtolower((string) $key), self::REDACTED_KEYS, true)) {
                $metadata[$key] = '[redacted]';
            }
        }

        return $metadata;
    }
}
