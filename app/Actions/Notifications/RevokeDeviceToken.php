<?php

namespace App\Actions\Notifications;

use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;

class RevokeDeviceToken
{
    /**
     * Unconditional and idempotent — matching RfidDevice's activate/revoke
     * simplicity (no InvalidTransitionException the way announcements/
     * attendance corrections have): revoking an already-revoked token is
     * harmless, so it isn't treated as an error.
     */
    public function __invoke(DeviceToken $deviceToken): DeviceToken
    {
        $deviceToken->update([
            'status' => DeviceTokenStatus::Revoked,
            'revoked_at' => now(),
        ]);

        return $deviceToken;
    }
}
