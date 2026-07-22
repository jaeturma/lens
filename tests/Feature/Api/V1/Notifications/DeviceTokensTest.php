<?php

use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;
use App\Models\Guardian;
use App\Models\User;

test('a guardian can register a device token', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', [
        'token' => 'fcm-token-1',
    ]);

    $response->assertOk()->assertJson(['success' => true]);
    expect(DeviceToken::query()->where('token', 'fcm-token-1')->exists())->toBeTrue();
});

test('registering a token requires the token field', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', []);

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('an unauthenticated request to register a device token is rejected', function () {
    bindSchool();

    $response = $this->postJson('/api/v1/notifications/device-tokens', ['token' => 'fcm-token-1']);

    $response->assertStatus(401);
});

test('a non-guardian account is rejected from registering a device token', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', ['token' => 'fcm-token-1']);

    $response->assertStatus(403);
});

test('a guardian-role account with no guardian profile yet is rejected from registering a device token', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', ['token' => 'fcm-token-1']);

    $response->assertStatus(403);
});

test('device token registration is rejected while the school is in maintenance mode', function () {
    bindSchool(['maintenance_mode' => true, 'maintenance_message' => 'Back soon.']);
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', ['token' => 'fcm-token-1']);

    $response->assertStatus(503)->assertJson(['success' => false, 'message' => 'Back soon.']);
});

test('a guardian can revoke their own device token', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create();
    $deviceToken = DeviceToken::factory()->for($guardian)->create(['token' => 'fcm-token-1']);
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->deleteJson('/api/v1/notifications/device-tokens', [
        'token' => 'fcm-token-1',
    ]);

    $response->assertOk()->assertJson(['success' => true]);
    expect($deviceToken->fresh()->status)->toBe(DeviceTokenStatus::Revoked);
});

test('a guardian cannot revoke another guardian\'s device token', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $otherGuardian = Guardian::factory()->create();
    $otherToken = DeviceToken::factory()->for($otherGuardian)->create(['token' => 'someone-elses-token']);
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->deleteJson('/api/v1/notifications/device-tokens', [
        'token' => 'someone-elses-token',
    ]);

    $response->assertStatus(404);
    expect($otherToken->fresh()->status)->toBe(DeviceTokenStatus::Active);
});

test('revoking an unknown token returns not found', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->deleteJson('/api/v1/notifications/device-tokens', [
        'token' => 'does-not-exist',
    ]);

    $response->assertStatus(404);
});

test('the device token registration endpoint is rate limited', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    for ($i = 0; $i < 30; $i++) {
        $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', ['token' => "fcm-token-{$i}"])
            ->assertOk();
    }

    $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', ['token' => 'fcm-token-30'])
        ->assertStatus(429);
});
