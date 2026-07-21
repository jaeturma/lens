<?php

namespace App\Enums;

enum RfidDeviceStatus: string
{
    case Active = 'active';
    case Revoked = 'revoked';
}
