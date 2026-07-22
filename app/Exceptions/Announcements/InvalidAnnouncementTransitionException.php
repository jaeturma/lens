<?php

namespace App\Exceptions\Announcements;

use App\Enums\AnnouncementStatus;
use RuntimeException;

class InvalidAnnouncementTransitionException extends RuntimeException
{
    public function __construct(AnnouncementStatus $from, AnnouncementStatus $to)
    {
        parent::__construct("Cannot transition an announcement from \"{$from->value}\" to \"{$to->value}\".");
    }
}
