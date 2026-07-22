<?php

use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\SyncChange;
use App\Models\User;
use Illuminate\Support\Str;

test('a guardian can mark their own notification as read', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create();
    $notification = GuardianNotification::factory()->for($guardian)->create(['read_at' => null]);
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->patchJson("/api/v1/notifications/{$notification->uuid}/read");

    $response->assertOk()->assertJson(['success' => true]);
    expect($notification->fresh()->read_at)->not->toBeNull();
});

test('marking an already-read notification is idempotent', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create();
    // Compared by whole-second timestamp — the datetime column truncates
    // sub-second precision on write, so the in-memory $readAt would never
    // equal a freshly-fetched value even when nothing actually changed.
    $readAt = now()->subDay();
    $notification = GuardianNotification::factory()->for($guardian)->create(['read_at' => $readAt]);
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->patchJson("/api/v1/notifications/{$notification->uuid}/read");

    $response->assertOk();
    expect($notification->fresh()->read_at->timestamp)->toBe($readAt->timestamp);
});

test('a guardian cannot mark another guardian\'s notification as read', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $otherGuardian = Guardian::factory()->create();
    $otherNotification = GuardianNotification::factory()->for($otherGuardian)->create(['read_at' => null]);
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->patchJson("/api/v1/notifications/{$otherNotification->uuid}/read");

    $response->assertStatus(404);
    expect($otherNotification->fresh()->read_at)->toBeNull();
});

test('marking an unknown notification returns not found', function () {
    bindSchool();
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->patchJson('/api/v1/notifications/'.Str::uuid().'/read');

    $response->assertStatus(404);
});

test('an unauthenticated request to mark a notification read is rejected', function () {
    bindSchool();
    $guardian = Guardian::factory()->create();
    $notification = GuardianNotification::factory()->for($guardian)->create();

    $response = $this->patchJson("/api/v1/notifications/{$notification->uuid}/read");

    $response->assertStatus(401);
});

test('a non-guardian account is rejected from marking a notification read', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $notification = GuardianNotification::factory()->for($guardian)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->patchJson("/api/v1/notifications/{$notification->uuid}/read");

    $response->assertStatus(403);
});

test('marking a notification read is rejected while the school is in maintenance mode', function () {
    bindSchool(['maintenance_mode' => true, 'maintenance_message' => 'Back soon.']);
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create();
    $notification = GuardianNotification::factory()->for($guardian)->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->patchJson("/api/v1/notifications/{$notification->uuid}/read");

    $response->assertStatus(503)->assertJson(['success' => false, 'message' => 'Back soon.']);
});

test('marking a notification as read records a sync_changes entry the guardian can pick up later', function () {
    bindSchool();
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create();
    $notification = GuardianNotification::factory()->for($guardian)->create(['read_at' => null]);
    $token = $user->createToken('mobile')->plainTextToken;

    $this->withToken($token)->patchJson("/api/v1/notifications/{$notification->uuid}/read")->assertOk();

    $change = SyncChange::query()
        ->where('resource_type', 'guardian_notification')
        ->where('resource_id', $notification->id)
        ->latest('id')
        ->first();

    expect($change)->not->toBeNull();
    expect($change->action->value)->toBe('updated');
    expect($change->payload['read_at'])->not->toBeNull();
});
