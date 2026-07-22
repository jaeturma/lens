<?php

use App\Enums\GuardianStatus;
use App\Models\Guardian;
use App\Models\User;
use App\Support\Sync\SyncCursor;

/**
 * WP-08-03: deactivating a guardian must revoke access, not just block a
 * future login attempt. Before `EnsureGuardianAccountIsActive`, a token
 * issued before deactivation kept working against every other endpoint
 * indefinitely — `docs/api/SYNC.md`'s own `guardian` section had
 * documented this as the current, unresolved behavior since WP-02-02.
 */
test('a deactivated guardian\'s existing token is rejected from /auth/me', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create(['status' => GuardianStatus::Active]);
    $token = $user->createToken('mobile')->plainTextToken;

    $guardian->update(['status' => GuardianStatus::Inactive]);

    $response = $this->withToken($token)->getJson('/api/v1/auth/me');

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a deactivated guardian\'s existing token is rejected from bootstrap', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create(['status' => GuardianStatus::Active]);
    $token = $user->createToken('mobile')->plainTextToken;

    $guardian->update(['status' => GuardianStatus::Inactive]);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a deactivated guardian\'s existing token is rejected from incremental sync', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create(['status' => GuardianStatus::Active]);
    $token = $user->createToken('mobile')->plainTextToken;

    $guardian->update(['status' => GuardianStatus::Inactive]);

    $response = $this->withToken($token)->getJson(
        '/api/v1/sync/changes?cursor='.(string) SyncCursor::initial()
    );

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a deactivated guardian\'s existing token is rejected from registering a device token', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create(['status' => GuardianStatus::Active]);
    $token = $user->createToken('mobile')->plainTextToken;

    $guardian->update(['status' => GuardianStatus::Inactive]);

    $response = $this->withToken($token)->postJson('/api/v1/notifications/device-tokens', [
        'token' => 'fcm-token-1',
    ]);

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a deactivated guardian can still log out with their existing token', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create(['status' => GuardianStatus::Active]);
    $token = $user->createToken('mobile')->plainTextToken;

    $guardian->update(['status' => GuardianStatus::Inactive]);

    $response = $this->withToken($token)->postJson('/api/v1/auth/logout');

    $response->assertOk()->assertJson(['success' => true]);
    expect($user->fresh()->tokens()->count())->toBe(0);
});

test('an active guardian\'s token is unaffected by the deactivation check', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create(['status' => GuardianStatus::Active]);
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/auth/me');

    $response->assertOk();
});

test('a guardian-role account with no Guardian profile yet is unaffected by the deactivation check', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/auth/me');

    $response->assertOk();
});

test('an administrator\'s token is unaffected by the deactivation check', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/auth/me');

    $response->assertOk();
});
