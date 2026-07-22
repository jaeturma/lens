<?php

use App\Enums\NotificationDeliveryStatus;
use App\Models\GuardianNotification;
use Illuminate\Support\Str;

test('a notification gets a uuid and defaults to pending delivery on creation', function () {
    $notification = GuardianNotification::factory()->create(['delivery_status' => null]);

    expect($notification->uuid)->not->toBeEmpty();
    expect($notification->delivery_status)->toBe(NotificationDeliveryStatus::Pending);
});

test('a notification uuid is immutable', function () {
    $notification = GuardianNotification::factory()->create();

    $notification->uuid = (string) Str::uuid();
    $notification->save();
})->throws(LogicException::class);

test('a notification starts unread', function () {
    $notification = GuardianNotification::factory()->create();

    expect($notification->read_at)->toBeNull();
});
