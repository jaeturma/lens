<?php

use App\Enums\GuardianStudentLinkStatus;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\Student;
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

test('bootstrap returns null guardian and empty children when there is no profile yet', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk()->assertJson([
        'data' => ['guardian' => null, 'children' => []],
    ]);
});

test('bootstrap returns the guardian profile and only actively linked children', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();

    $activeStudent = Student::factory()->create();
    $revokedStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($activeStudent)->create([
        'status' => GuardianStudentLinkStatus::Active,
        'relationship_type' => 'mother',
    ]);
    GuardianStudentLink::factory()->for($guardian)->for($revokedStudent)->create([
        'status' => GuardianStudentLinkStatus::Revoked,
    ]);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk()->assertJson([
        'data' => [
            'guardian' => ['uuid' => $guardian->uuid, 'email' => $guardian->email],
        ],
    ]);

    $children = $response->json('data.children');
    expect($children)->toHaveCount(1);
    expect($children[0]['uuid'])->toBe($activeStudent->uuid);
    expect($children[0]['relationship_type'])->toBe('mother');
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
