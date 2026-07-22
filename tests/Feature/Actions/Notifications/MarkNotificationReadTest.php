<?php

use App\Actions\Notifications\MarkNotificationRead;
use App\Models\GuardianNotification;

test('it sets read_at on an unread notification', function () {
    $notification = GuardianNotification::factory()->create(['read_at' => null]);

    (new MarkNotificationRead)($notification);

    expect($notification->fresh()->read_at)->not->toBeNull();
});

test('it leaves an already-read notification\'s read_at untouched', function () {
    // Compared by whole-second timestamp, not Carbon equality: the
    // datetime column truncates sub-second precision on write, so the
    // in-memory $readAt (still microsecond-precise) would never equal a
    // freshly-fetched value even when nothing was actually changed.
    $readAt = now()->subDay();
    $notification = GuardianNotification::factory()->create(['read_at' => $readAt]);

    (new MarkNotificationRead)($notification);

    expect($notification->fresh()->read_at->timestamp)->toBe($readAt->timestamp);
});
