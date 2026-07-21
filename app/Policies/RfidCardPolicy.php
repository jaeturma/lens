<?php

namespace App\Policies;

use App\Models\RfidCard;
use App\Models\User;

class RfidCardPolicy
{
    public function viewAny(User $user): bool
    {
        return $user->isAdministrator();
    }

    public function view(User $user, RfidCard $card): bool
    {
        return $user->isAdministrator();
    }

    public function create(User $user): bool
    {
        return $user->isAdministrator();
    }

    public function update(User $user, RfidCard $card): bool
    {
        return $user->isAdministrator();
    }
}
