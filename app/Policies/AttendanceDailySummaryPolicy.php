<?php

namespace App\Policies;

use App\Models\AttendanceDailySummary;
use App\Models\User;

class AttendanceDailySummaryPolicy
{
    public function update(User $user, AttendanceDailySummary $summary): bool
    {
        return $user->isAdministrator();
    }
}
