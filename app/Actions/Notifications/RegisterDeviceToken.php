<?php

namespace App\Actions\Notifications;

use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;
use App\Models\Guardian;

class RegisterDeviceToken
{
    /**
     * Registers a token for a guardian, or refreshes an existing
     * registration when $previousToken is given (Firebase rotates a
     * device's token periodically; the client is expected to tell the
     * server which token the new one replaces).
     *
     * Duplicate tokens are handled by claiming, not erroring: `token` is
     * globally unique, so if the given token already has a row — under
     * this guardian (a redundant re-register, e.g. app restart) or under
     * a different one (the same physical device previously belonged to
     * another guardian's login) — that row is reactivated and reassigned
     * to the current guardian rather than attempting a second INSERT that
     * would violate the unique constraint.
     */
    public function __invoke(Guardian $guardian, string $token, ?string $previousToken = null): DeviceToken
    {
        if ($previousToken !== null && $previousToken !== $token) {
            DeviceToken::query()
                ->where('token', $previousToken)
                ->where('guardian_id', $guardian->id)
                ->update(['status' => DeviceTokenStatus::Revoked, 'revoked_at' => now()]);
        }

        $existing = DeviceToken::query()->where('token', $token)->first();

        if ($existing) {
            $existing->update([
                'guardian_id' => $guardian->id,
                'status' => DeviceTokenStatus::Active,
                'revoked_at' => null,
            ]);

            return $existing;
        }

        return DeviceToken::create([
            'guardian_id' => $guardian->id,
            'token' => $token,
            'status' => DeviceTokenStatus::Active,
        ]);
    }
}
