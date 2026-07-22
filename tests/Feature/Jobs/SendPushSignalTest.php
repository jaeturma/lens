<?php

use App\Enums\DeviceTokenStatus;
use App\Enums\NotificationDeliveryStatus;
use App\Jobs\SendPushSignal;
use App\Models\DeviceToken;
use App\Models\GuardianNotification;
use App\Models\PushDeliveryAttempt;
use Illuminate\Support\Facades\Queue;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Exception\Messaging\NotFound;
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

test('a successful attempt is logged with the current attempt number', function () {
    $notification = GuardianNotification::factory()->create();
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active]);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')->once()->andReturn(MulticastSendReport::withItems([
        SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'a-token'), []),
    ]));

    (new SendPushSignal($notification))->handle($messaging);

    $attempt = PushDeliveryAttempt::query()->where('guardian_notification_id', $notification->id)->firstOrFail();
    expect($attempt->attempt_number)->toBe(1);
    expect($attempt->succeeded)->toBeTrue();
    expect($attempt->error_message)->toBeNull();
});

test('a failed attempt is logged with the error message, and attempt numbers increment across retries', function () {
    $notification = GuardianNotification::factory()->create();
    DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active]);

    $failingMessaging = Mockery::mock(Messaging::class);
    $failingMessaging->shouldReceive('sendMulticast')->once()->andThrow(new RuntimeException('Firebase unreachable'));
    (new SendPushSignal($notification))->handle($failingMessaging);

    $succeedingMessaging = Mockery::mock(Messaging::class);
    $succeedingMessaging->shouldReceive('sendMulticast')->once()->andReturn(MulticastSendReport::withItems([
        SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'a-token'), []),
    ]));
    (new SendPushSignal($notification))->handle($succeedingMessaging);

    $attempts = PushDeliveryAttempt::query()->where('guardian_notification_id', $notification->id)->orderBy('attempt_number')->get();
    expect($attempts)->toHaveCount(2);
    expect($attempts[0]->attempt_number)->toBe(1);
    expect($attempts[0]->succeeded)->toBeFalse();
    expect($attempts[0]->error_message)->toBe('Firebase unreachable');
    expect($attempts[1]->attempt_number)->toBe(2);
    expect($attempts[1]->succeeded)->toBeTrue();
});

test('a token Firebase reports as not found is deactivated, safely — only that token, not the others', function () {
    $notification = GuardianNotification::factory()->create();
    $bad = DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active, 'token' => 'bad-token']);
    $good = DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active, 'token' => 'good-token']);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')->once()->andReturn(MulticastSendReport::withItems([
        SendReport::failure(MessageTarget::with(MessageTarget::TOKEN, 'bad-token'), NotFound::becauseTokenNotFound('bad-token')),
        SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'good-token'), []),
    ]));

    (new SendPushSignal($notification))->handle($messaging);

    expect($bad->fresh()->status)->toBe(DeviceTokenStatus::Deactivated);
    expect($good->fresh()->status)->toBe(DeviceTokenStatus::Active);
});

test('a general delivery exception never deactivates any device token', function () {
    $notification = GuardianNotification::factory()->create();
    $deviceToken = DeviceToken::factory()->for($notification->guardian)->create(['status' => DeviceTokenStatus::Active]);

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')->once()->andThrow(new RuntimeException('Firebase unreachable'));

    (new SendPushSignal($notification))->handle($messaging);

    expect($deviceToken->fresh()->status)->toBe(DeviceTokenStatus::Active);
});

test('creating a guardian notification queues the push signal job', function () {
    Queue::fake();

    $notification = GuardianNotification::factory()->create();

    Queue::assertPushed(SendPushSignal::class, fn (SendPushSignal $job) => $job->notification->is($notification));
});
