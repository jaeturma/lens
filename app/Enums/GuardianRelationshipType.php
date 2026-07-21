<?php

namespace App\Enums;

enum GuardianRelationshipType: string
{
    case Mother = 'mother';
    case Father = 'father';
    case Guardian = 'guardian';
    case Other = 'other';
}
