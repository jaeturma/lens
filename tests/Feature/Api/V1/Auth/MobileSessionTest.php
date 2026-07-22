<?php

use App\Models\User;
use Laravel\Sanctum\PersonalAccessToken;

test('an authenticated request returns the current user', function () {
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/auth/me');

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => ['id' => $user->id, 'email' => $user->email],
    ]);
});

test('an unauthenticated request to me is rejected', function () {
    $response = $this->getJson('/api/v1/auth/me');

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('logout revokes the current token', function () {
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $this->withToken($token)->postJson('/api/v1/auth/logout')
        ->assertOk()->assertJson(['success' => true]);

    expect($user->fresh()->tokens()->count())->toBe(0);
});

test('a revoked token can no longer authenticate', function () {
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    PersonalAccessToken::findToken($token)->delete();

    $this->withToken($token)->getJson('/api/v1/auth/me')
        ->assertStatus(401);
});

test('auth/me is rate limited per user (WP-08-06)', function () {
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    for ($i = 0; $i < 60; $i++) {
        $this->withToken($token)->getJson('/api/v1/auth/me')->assertOk();
    }

    $this->withToken($token)->getJson('/api/v1/auth/me')->assertStatus(429);
});
