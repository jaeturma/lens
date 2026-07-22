<?php

use App\Enums\DeviceTokenStatus;
use App\Enums\NotificationDeliveryStatus;
use App\Jobs\SendPushSignal;
use App\Models\DeviceToken;
use App\Models\GuardianNotification;
use Illuminate\Support\Facades\Queue;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\MessageTarget;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Kreait\Firebase\Messaging\SendReport;

test('a successful send marks the notification delivered', function () {
    $notification = GuardianNotification::factory()->create();
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active]);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')
        ->once()
        ->andReturn(MulticastSendReport::withItems([
            SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'a-token'), []),
        ]));

    (new SendPushSignal($notification))->handle($messaging);

    expect($notification->fresh()->delivery_status)->toBe(NotificationDeliveryStatus::Sent);
});

test('a total send failure marks the notification failed but keeps the record', function () {
    $notification = GuardianNotification::factory()->create();
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active]);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')
        ->once()
        ->andThrow(new RuntimeException('Firebase unreachable'));

    (new SendPushSignal($notification))->handle($messaging);

    expect($notification->fresh())->not->toBeNull();
    expect($notification->fresh()->delivery_status)->toBe(NotificationDeliveryStatus::Failed);
});

test('a guardian with no active device tokens is left pending without attempting delivery', function () {
    $notification = GuardianNotification::factory()->create();
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Revoked]);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldNotReceive('sendMulticast');

    (new SendPushSignal($notification))->handle($messaging);

    expect($notification->fresh()->delivery_status)->toBe(NotificationDeliveryStatus::Pending);
});

test('only active device tokens are targeted', function () {
    $notification = GuardianNotification::factory()->create();
    $active = DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active, 'token' => 'active-token']);
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Revoked, 'token' => 'revoked-token']);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')
        ->once()
        ->withArgs(fn (CloudMessage $message, array $tokens) => $tokens === [$active->token])
        ->andReturn(MulticastSendReport::withItems([
            SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'active-token'), []),
        ]));

    (new SendPushSignal($notification))->handle($messaging);
});

test('the push payload carries no title, body, or attendance/announcement content', function () {
    $notification = GuardianNotification::factory()->create([
        'title' => 'Juan has arrived',
        'body' => 'Juan arrived at school.',
    ]);
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active]);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')
        ->once()
        ->withArgs(function (CloudMessage $message) {
            $serialized = $message->jsonSerialize();

            expect($serialized)->not->toHaveKey('notification');
            expect($serialized)->toHaveKey('data');
            expect(json_encode($serialized))->not->toContain('arrived');

            return true;
        })
        ->andReturn(MulticastSendReport::withItems([
            SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'a-token'), []),
        ]));

    (new SendPushSignal($notification))->handle($messaging);
});

test('creating a guardian notification queues the push signal job', function () {
    Queue::fake();

    $notification = GuardianNotification::factory()->create();

    Queue::assertPushed(SendPushSignal::class, fn (SendPushSignal $job) => $job->notification->is($notification));
});
