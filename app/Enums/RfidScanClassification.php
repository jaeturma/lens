<?php

namespace App\Enums;

enum RfidScanClassification: string
{
    case Valid = 'valid';
    case DuplicateWindow = 'duplicate_window';
    case UnknownCard = 'unknown_card';
    case InactiveCard = 'inactive_card';
}
