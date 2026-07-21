<?php

namespace App\Exceptions\RfidCards;

use RuntimeException;
use Throwable;

class RfidUidAlreadyActiveException extends RuntimeException
{
    public function __construct(string $uid, ?Throwable $previous = null)
    {
        parent::__construct("RFID UID \"{$uid}\" is already actively assigned to another card.", previous: $previous);
    }
}
