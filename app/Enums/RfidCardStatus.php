<?php

namespace App\Enums;

enum RfidCardStatus: string
{
    case Active = 'active';
    case Deactivated = 'deactivated';
    case Replaced = 'replaced';
}
