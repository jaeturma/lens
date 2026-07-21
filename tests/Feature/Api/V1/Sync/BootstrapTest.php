<?php

use App\Models\User;

test('bootstrap returns the school profile, user, and a usable cursor', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'school' => ['school_id' => 'SCH-0001'],
            'user' => ['id' => $user->id, 'email' => $user->email],
        ],
    ]);

    expect($response->json('data.next_cursor'))->toBeString()->not->toBeEmpty();
});

test('an unauthenticated bootstrap request is rejected', function () {
    bindSchool();

    $response = $this->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a non-guardian account is rejected from bootstrap', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(403)->assertJson(['success' => false]);
});

test('bootstrap is rejected while the school is in maintenance mode', function () {
    bindSchool(['maintenance_mode' => true, 'maintenance_message' => 'Back soon.']);
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(503)->assertJson(['success' => false, 'message' => 'Back soon.']);
});

test('the bootstrap endpoint is rate limited', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    for ($i = 0; $i < 30; $i++) {
        $this->withToken($token)->getJson('/api/v1/sync/bootstrap')->assertOk();
    }

    $this->withToken($token)->getJson('/api/v1/sync/bootstrap')->assertStatus(429);
});
