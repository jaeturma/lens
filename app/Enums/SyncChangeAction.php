<?php

namespace App\Enums;

enum SyncChangeAction: string
{
    case Created = 'created';
    case Updated = 'updated';
    case Deleted = 'deleted';
    case Revoked = 'revoked';
    case Expired = 'expired';
    case Corrected = 'corrected';
}
