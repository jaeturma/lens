<?php

use App\Enums\NotificationType;
use App\Enums\SyncChangeAction;
use App\Models\GuardianNotification;
use App\Models\SyncChange;

test('creating a notification records a sync change', function () {
    $notification = GuardianNotification::factory()->create(['type' => NotificationType::Arrival]);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'guardian_notification',
        'resource_id' => $notification->id,
        'action' => SyncChangeAction::Created->value,
    ]);
});

test('marking a notification read records a sync change with the updated read state', function () {
    $notification = GuardianNotification::factory()->create();

    $notification->update(['read_at' => now()]);

    $change = SyncChange::query()
        ->where('resource_type', 'guardian_notification')
        ->where('resource_id', $notification->id)
        ->where('action', SyncChangeAction::Updated->value)
        ->latest('id')
        ->firstOrFail();

    expect($change->payload['read_at'])->not->toBeNull();
});

test('the sync payload carries the notification type, guardian, and delivery status', function () {
    $notification = GuardianNotification::factory()->create([
        'type' => NotificationType::AnnouncementPublished,
        'payload' => ['announcement_id' => 42],
    ]);

    $change = SyncChange::query()->where('resource_type', 'guardian_notification')->where('resource_id', $notification->id)->firstOrFail();

    expect($change->payload['guardian_id'])->toBe($notification->guardian_id);
    expect($change->payload['type'])->toBe('announcement_published');
    expect($change->payload['payload'])->toBe(['announcement_id' => 42]);
    expect($change->payload['delivery_status'])->toBe('pending');
});
