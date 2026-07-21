<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    /**
     * A user may only view their own account. This is the enforced
     * isolation rule for guardian-owned data: no user may read another
     * user's record, regardless of role.
     */
    public function view(User $user, User $target): bool
    {
        return $user->id === $target->id;
    }

    /**
     * A user may only update their own account.
     */
    public function update(User $user, User $target): bool
    {
        return $user->id === $target->id;
    }
}
