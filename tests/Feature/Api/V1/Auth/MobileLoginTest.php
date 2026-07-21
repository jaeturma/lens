<?php

use App\Models\User;
use Illuminate\Support\Facades\Hash;

test('a valid guardian login issues a mobile token', function () {
    bindSchool();
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'correct-password',
    ]);

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'user' => ['email' => $user->email],
        ],
    ]);

    expect($response->json('data.token'))->toBeString()->not->toBeEmpty();
    expect($user->fresh()->tokens()->count())->toBe(1);
});

test('login requires a school id that resolves to a configured school', function () {
    bindSchool();
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'DOES-NOT-EXIST',
        'email' => $user->email,
        'password' => 'correct-password',
    ]);

    $response->assertStatus(422)->assertJson([
        'success' => false,
    ]);

    expect($response->json('errors.school_id'))->not->toBeEmpty();
});

test('an incorrect password is rejected without issuing a token', function () {
    bindSchool();
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'wrong-password',
    ]);

    $response->assertStatus(422)->assertJson(['success' => false]);
    expect($user->fresh()->tokens()->count())->toBe(0);
});

test('login is rejected while the school is in maintenance mode', function () {
    bindSchool(['maintenance_mode' => true, 'maintenance_message' => 'Back soon.']);
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'correct-password',
    ]);

    $response->assertStatus(503)->assertJson([
        'success' => false,
        'message' => 'Back soon.',
    ]);
});

test('login is rejected when mobile access is disabled', function () {
    bindSchool(['mobile_enabled' => false]);
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'correct-password',
    ]);

    $response->assertStatus(503)->assertJson(['success' => false]);
});

test('login is rejected when the app version is below the minimum', function () {
    bindSchool(['minimum_app_version' => '2.0.0']);
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'correct-password',
    ], ['X-App-Version' => '1.0.0']);

    $response->assertStatus(426)->assertJson(['success' => false]);
});

test('a non-guardian account is rejected from mobile login', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create(['password' => Hash::make('correct-password')]);

    $response = $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'correct-password',
    ]);

    $response->assertStatus(403)->assertJson(['success' => false]);
    expect($user->fresh()->tokens()->count())->toBe(0);
});

test('the mobile login endpoint is rate limited', function () {
    bindSchool();
    $user = User::factory()->create(['password' => Hash::make('correct-password')]);

    for ($i = 0; $i < 5; $i++) {
        $this->postJson('/api/v1/auth/login', [
            'school_id' => 'SCH-0001',
            'email' => $user->email,
            'password' => 'wrong-password',
        ])->assertStatus(422);
    }

    $this->postJson('/api/v1/auth/login', [
        'school_id' => 'SCH-0001',
        'email' => $user->email,
        'password' => 'wrong-password',
    ])->assertStatus(429);
});
