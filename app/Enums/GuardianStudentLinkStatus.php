<?php

namespace App\Enums;

enum GuardianStudentLinkStatus: string
{
    case Active = 'active';
    case Revoked = 'revoked';
}
