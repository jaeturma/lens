<?php

namespace App\Enums;

enum AttendanceEventType: string
{
    case Arrival = 'arrival';
    case Departure = 'departure';
}
