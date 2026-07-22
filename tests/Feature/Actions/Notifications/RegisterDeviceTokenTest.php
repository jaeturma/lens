<?php

use App\Actions\Notifications\RegisterDeviceToken;
use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;
use App\Models\Guardian;

test('registering a new token creates an active row for the guardian', function () {
    $guardian = Guardian::factory()->create();

    $token = app(RegisterDeviceToken::class)($guardian, 'fcm-token-1');

    expect($token->guardian_id)->toBe($guardian->id);
    expect($token->status)->toBe(DeviceTokenStatus::Active);
    expect(DeviceToken::query()->count())->toBe(1);
});

test('re-registering the same token for the same guardian is idempotent', function () {
    $guardian = Guardian::factory()->create();

    app(RegisterDeviceToken::class)($guardian, 'fcm-token-1');
    app(RegisterDeviceToken::class)($guardian, 'fcm-token-1');

    expect(DeviceToken::query()->count())->toBe(1);
});

test('registering a token already claimed by a different guardian reassigns it', function () {
    $originalGuardian = Guardian::factory()->create();
    $newGuardian = Guardian::factory()->create();
    DeviceToken::factory()->for($originalGuardian)->create(['token' => 'fcm-token-1']);

    app(RegisterDeviceToken::class)($newGuardian, 'fcm-token-1');

    expect(DeviceToken::query()->count())->toBe(1);
    $token = DeviceToken::query()->firstOrFail();
    expect($token->guardian_id)->toBe($newGuardian->id);
    expect($token->status)->toBe(DeviceTokenStatus::Active);
});

test('registering a token reactivates it if it was previously revoked', function () {
    $guardian = Guardian::factory()->create();
    DeviceToken::factory()->for($guardian)->create([
        'token' => 'fcm-token-1',
        'status' => DeviceTokenStatus::Revoked,
        'revoked_at' => now(),
    ]);

    $token = app(RegisterDeviceToken::class)($guardian, 'fcm-token-1');

    expect($token->status)->toBe(DeviceTokenStatus::Active);
    expect($token->revoked_at)->toBeNull();
});

test('refreshing a token revokes the previous one and activates the new one', function () {
    $guardian = Guardian::factory()->create();
    DeviceToken::factory()->for($guardian)->create(['token' => 'old-token']);

    app(RegisterDeviceToken::class)($guardian, 'new-token', 'old-token');

    $old = DeviceToken::query()->where('token', 'old-token')->firstOrFail();
    $new = DeviceToken::query()->where('token', 'new-token')->firstOrFail();
    expect($old->status)->toBe(DeviceTokenStatus::Revoked);
    expect($new->status)->toBe(DeviceTokenStatus::Active);
    expect(DeviceToken::query()->count())->toBe(2);
});

test('refreshing does not revoke a previous_token owned by a different guardian', function () {
    $guardian = Guardian::factory()->create();
    $otherGuardian = Guardian::factory()->create();
    DeviceToken::factory()->for($otherGuardian)->create(['token' => 'other-guardians-token']);

    app(RegisterDeviceToken::class)($guardian, 'new-token', 'other-guardians-token');

    $untouched = DeviceToken::query()->where('token', 'other-guardians-token')->firstOrFail();
    expect($untouched->status)->toBe(DeviceTokenStatus::Active);
});
