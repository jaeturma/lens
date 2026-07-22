<?php

use App\Actions\RfidCards\AssignRfidCard;
use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Enums\DeviceTokenStatus;
use App\Enums\NotificationDeliveryStatus;
use App\Enums\NotificationType;
use App\Enums\RfidDeviceDirectionMode;
use App\Jobs\SendPushSignal;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\DeviceToken;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;
use App\Models\PushDeliveryAttempt;
use App\Models\RfidScan;
use App\Models\Student;
use App\Models\SyncChange;
use App\Support\Sync\SyncCursor;
use Illuminate\Support\Facades\Queue;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\MessageTarget;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Kreait\Firebase\Messaging\SendReport;

/**
 * WP-08-05: the one place the whole chain — scan -> raw record -> attendance
 * -> notification -> push signal -> sync -> guardian-visible state — is
 * exercised together, starting from the real HTTP scan endpoint rather than
 * calling each link's own Action/Observer directly the way every other test
 * in the suite does (unit-level coverage for each individual link already
 * exists and is not duplicated here).
 *
 * `tests/Pest.php` fakes the queue globally for every Feature test, so
 * `App\Jobs\SendPushSignal` never runs as an inline side effect of creating
 * a `GuardianNotification` — exactly like `tests/Feature/Jobs/SendPushSignalTest.php`
 * already established, the job is asserted queued via `Queue::assertPushed`
 * and then invoked directly with a mocked `Messaging`, rather than relying
 * on the sync queue driver to run it inline.
 */
function setUpArrivalPipelineFixtures(): array
{
    bindSchool();
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $student = Student::factory()->create();
    app(AssignRfidCard::class)($student, 'ABCD1234');
    $guardian = Guardian::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create();
    DeviceToken::factory()->for($guardian)->create(['status' => DeviceTokenStatus::Active]);

    return [$registration, $student, $guardian];
}

test('a valid scan flows end-to-end through raw record, attendance, notification, and a successful push signal', function () {
    [$registration, $student, $guardian] = setUpArrivalPipelineFixtures();

    Queue::fake();

    $response = $this->withHeaders(['Authorization' => 'Basic '.base64_encode('GATE-001:'.$registration->plainSecret)])
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'ABCD1234',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ]);

    $response->assertOk();

    // Raw record.
    $scan = RfidScan::query()->where('request_id', 'seq-1')->firstOrFail();
    expect($scan->classification->value)->toBe('valid');

    // Attendance.
    $event = AttendanceEvent::query()->where('rfid_scan_id', $scan->id)->firstOrFail();
    expect($event->event_type->value)->toBe('arrival');
    $summary = AttendanceDailySummary::query()->where('student_id', $student->id)->firstOrFail();
    expect($summary->arrival_event_id)->toBe($event->id);

    // Notification.
    $notification = GuardianNotification::query()->where('guardian_id', $guardian->id)->firstOrFail();
    expect($notification->type)->toBe(NotificationType::Arrival);
    expect($notification->delivery_status)->toBe(NotificationDeliveryStatus::Pending);

    // Sync change feed — both the summary and the notification are
    // recorded, not just the raw scan.
    expect(SyncChange::query()->where('resource_type', 'attendance_daily_summary')->where('resource_id', $summary->id)->exists())->toBeTrue();
    expect(SyncChange::query()->where('resource_type', 'guardian_notification')->where('resource_id', $notification->id)->exists())->toBeTrue();

    // Push signal queued (globally faked — see file docblock) with the
    // right notification, then actually delivered — the same "call
    // handle() directly" shape SendPushSignalTest.php already uses.
    Queue::assertPushed(SendPushSignal::class, fn (SendPushSignal $job) => $job->notification->is($notification));

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')->once()->andReturn(MulticastSendReport::withItems([
        SendReport::success(MessageTarget::with(MessageTarget::TOKEN, 'a-token'), []),
    ]));
    (new SendPushSignal($notification))->handle($messaging);

    expect($notification->fresh()->delivery_status)->toBe(NotificationDeliveryStatus::Sent);
    $attempt = PushDeliveryAttempt::query()->where('guardian_notification_id', $notification->id)->firstOrFail();
    expect($attempt->succeeded)->toBeTrue();

    // Sync, from the guardian's own device — the feed the mobile app
    // actually reads carries both changes, scoped correctly.
    $token = $guardian->user->createToken('mobile')->plainTextToken;
    $syncResponse = $this->withToken($token)->getJson(
        '/api/v1/sync/changes?cursor='.(string) SyncCursor::initial()
    );
    $syncResponse->assertOk();
    $resourceTypes = collect($syncResponse->json('data.changes'))->pluck('resource_type');
    expect($resourceTypes)->toContain('attendance_daily_summary');
    expect($resourceTypes)->toContain('guardian_notification');
});

test('a push signal failure does not lose the notification and is traceable, and the guardian still receives it via ordinary sync', function () {
    [$registration, $student, $guardian] = setUpArrivalPipelineFixtures();

    Queue::fake();

    $this->withHeaders(['Authorization' => 'Basic '.base64_encode('GATE-001:'.$registration->plainSecret)])
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'ABCD1234',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ])->assertOk();

    $notification = GuardianNotification::query()->where('guardian_id', $guardian->id)->firstOrFail();

    $capturedJob = null;
    Queue::assertPushed(SendPushSignal::class, function (SendPushSignal $job) use (&$capturedJob) {
        $capturedJob = $job;

        return true;
    });

    $messaging = Mockery::mock(Messaging::class);
    $messaging->shouldReceive('sendMulticast')->once()->andThrow(new RuntimeException('Firebase unreachable'));
    $capturedJob->handle($messaging);

    // Traceable: the failure is a queryable, attributable record, not a
    // swallowed exception — same guarantee `SendPushSignalTest.php` proves
    // at the job level, confirmed here still holds reached from the real
    // HTTP entrypoint.
    expect($notification->fresh()->delivery_status)->toBe(NotificationDeliveryStatus::Failed);
    $attempt = PushDeliveryAttempt::query()->where('guardian_notification_id', $notification->id)->firstOrFail();
    expect($attempt->succeeded)->toBeFalse();
    expect($attempt->error_message)->toBe('Firebase unreachable');

    // Not lost: the notification row and its sync_changes entry are
    // completely untouched by the delivery failure — the guardian's next
    // ordinary sync (app resume, startup, or a manual pull-to-refresh —
    // not another push, since none is expected to arrive) still carries it.
    expect(SyncChange::query()->where('resource_type', 'guardian_notification')->where('resource_id', $notification->id)->exists())->toBeTrue();

    $token = $guardian->user->createToken('mobile')->plainTextToken;
    $syncResponse = $this->withToken($token)->getJson(
        '/api/v1/sync/changes?cursor='.(string) SyncCursor::initial()
    );
    $syncResponse->assertOk();
    $notificationChange = collect($syncResponse->json('data.changes'))
        ->where('resource_type', 'guardian_notification')
        ->firstWhere('resource_id', $notification->id);
    expect($notificationChange)->not->toBeNull();
});
