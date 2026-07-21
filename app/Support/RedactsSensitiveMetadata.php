<?php

namespace App\Support;

trait RedactsSensitiveMetadata
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
