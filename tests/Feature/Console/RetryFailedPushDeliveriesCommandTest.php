<?php

use App\Enums\NotificationDeliveryStatus;
use App\Jobs\SendPushSignal;
use App\Models\GuardianNotification;
use App\Models\PushDeliveryAttempt;
use Illuminate\Support\Facades\Queue;

test('the notifications:retry-failed-push command re-dispatches under-cap failed notifications and reports the count', function () {
    Queue::fake();

    $notification = GuardianNotification::factory()->create(['delivery_status' => NotificationDeliveryStatus::Failed]);
    PushDeliveryAttempt::factory()->for($notification, 'guardianNotification')->create(['attempt_number' => 1, 'succeeded' => false]);

    $this->artisan('notifications:retry-failed-push')
        ->expectsOutputToContain('Re-dispatched 1 notification(s) for retry.')
        ->assertSuccessful();

    Queue::assertPushed(SendPushSignal::class, fn ($job) => $job->notification->is($notification));
});

test('a failed notification that has exhausted the maximum attempts is not retried', function () {
    Queue::fake();

    $notification = GuardianNotification::factory()->create(['delivery_status' => NotificationDeliveryStatus::Failed]);
    PushDeliveryAttempt::factory()->for($notification, 'guardianNotification')->create(['attempt_number' => 1, 'succeeded' => false]);
    PushDeliveryAttempt::factory()->for($notification, 'guardianNotification')->create(['attempt_number' => 2, 'succeeded' => false]);
    PushDeliveryAttempt::factory()->for($notification, 'guardianNotification')->create(['attempt_number' => 3, 'succeeded' => false]);

    Queue::fake();

    $this->artisan('notifications:retry-failed-push')
        ->expectsOutputToContain('Re-dispatched 0 notification(s) for retry.')
        ->assertSuccessful();

    Queue::assertNotPushed(SendPushSignal::class);
});

test('a notification that is not Failed is not retried', function () {
    Queue::fake();

    GuardianNotification::factory()->create(['delivery_status' => NotificationDeliveryStatus::Sent]);
    GuardianNotification::factory()->create(['delivery_status' => NotificationDeliveryStatus::Pending]);

    Queue::fake();

    $this->artisan('notifications:retry-failed-push')
        ->expectsOutputToContain('Re-dispatched 0 notification(s) for retry.')
        ->assertSuccessful();

    Queue::assertNotPushed(SendPushSignal::class);
});
