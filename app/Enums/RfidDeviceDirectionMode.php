<?php

namespace App\Enums;

enum RfidDeviceDirectionMode: string
{
    case Entry = 'entry';
    case Exit = 'exit';
    case Both = 'both';
}
