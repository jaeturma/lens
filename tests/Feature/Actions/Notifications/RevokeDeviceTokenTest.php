<?php

use App\Actions\Notifications\RevokeDeviceToken;
use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;

test('revoking an active token marks it revoked', function () {
    $token = DeviceToken::factory()->create(['status' => DeviceTokenStatus::Active]);

    app(RevokeDeviceToken::class)($token);

    expect($token->fresh()->status)->toBe(DeviceTokenStatus::Revoked);
    expect($token->fresh()->revoked_at)->not->toBeNull();
});

test('revoking an already-revoked token is a harmless no-op', function () {
    $token = DeviceToken::factory()->create(['status' => DeviceTokenStatus::Revoked, 'revoked_at' => now()->subDay()]);

    app(RevokeDeviceToken::class)($token);

    expect($token->fresh()->status)->toBe(DeviceTokenStatus::Revoked);
});
