<?php

namespace App\Policies;

use App\Models\RfidDevice;
use App\Models\User;

class RfidDevicePolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isAdministrator();
    }

    public function view(User $user, RfidDevice $device): bool
    {
        return $user->isAdministrator();
    }

    public function create(User $user): bool
    {
        return $user->isAdministrator();
    }

    public function update(User $user, RfidDevice $device): bool
    {
        return $user->isAdministrator();
    }
}
