<?php

namespace App\Enums;

/**
 * Initial-release roles per docs/SECURITY.md Roles and Permission Matrix.
 * RFID Device is not a user account and has no case here.
 */
enum UserRole: string
{
    case SystemAdministrator = 'system_administrator';
    case SchoolAdministrator = 'school_administrator';
    case Guardian = 'guardian';

    public function isAdministrator(): bool
    {
        return $this === self::SystemAdministrator || $this === self::SchoolAdministrator;
    }
}
