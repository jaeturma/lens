<?php

namespace App\Support\Sync;

use InvalidArgumentException;

final class SyncCursor
{
    private function __construct(private readonly int $sequence)
    {
        if ($sequence < 0) {
            throw new InvalidArgumentException('A sync cursor sequence cannot be negative.');
        }
    }

    public static function initial(): self
    {
        return new self(0);
    }

    public static function fromSequence(int $sequence): self
    {
        return new self($sequence);
    }

    public static function fromString(string $cursor): self
    {
        $decoded = base64_decode($cursor, strict: true);

        if ($decoded === false || $decoded === '' || ! ctype_digit($decoded)) {
            throw new InvalidArgumentException('The sync cursor is malformed.');
        }

        return self::fromSequence((int) $decoded);
    }

    public function sequence(): int
    {
        return $this->sequence;
    }

    public function encode(): string
    {
        return base64_encode((string) $this->sequence);
    }

    public function __toString(): string
    {
        return $this->encode();
    }
}
