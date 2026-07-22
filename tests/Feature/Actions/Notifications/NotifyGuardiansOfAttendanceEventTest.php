<?php

use App\Actions\Notifications\NotifyGuardiansOfAttendanceEvent;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\NotificationType;
use App\Models\AttendanceDailySummary;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;
use App\Models\Student;

test('every active, notify_attendance-enabled guardian gets their own notification', function () {
    $student = Student::factory()->create();
    $notifying = Guardian::factory()->create(['notify_attendance' => true]);
    $optedOut = Guardian::factory()->create(['notify_attendance' => false]);
    $revoked = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($notifying)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    GuardianStudentLink::factory()->for($optedOut)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    GuardianStudentLink::factory()->for($revoked)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $summary = AttendanceDailySummary::factory()->for($student)->create();

    app(NotifyGuardiansOfAttendanceEvent::class)($summary, NotificationType::Arrival);

    expect(GuardianNotification::query()->count())->toBe(1);
    $notification = GuardianNotification::query()->firstOrFail();
    expect($notification->guardian_id)->toBe($notifying->id);
    expect($notification->type)->toBe(NotificationType::Arrival);
});

test('a student with no qualifying guardians produces no notifications', function () {
    $student = Student::factory()->create();
    $summary = AttendanceDailySummary::factory()->for($student)->create();

    app(NotifyGuardiansOfAttendanceEvent::class)($summary, NotificationType::Departure);

    expect(GuardianNotification::query()->count())->toBe(0);
});

test('the notification payload references the student, summary, and date', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $summary = AttendanceDailySummary::factory()->for($student)->create(['date' => '2026-07-22']);

    app(NotifyGuardiansOfAttendanceEvent::class)($summary, NotificationType::Absence);

    $notification = GuardianNotification::query()->firstOrFail();
    expect($notification->payload)->toBe([
        'student_id' => $student->id,
        'attendance_daily_summary_id' => $summary->id,
        'date' => '2026-07-22',
    ]);
});

test('title and body differ by notification type', function () {
    $student = Student::factory()->create(['name' => 'Juan Dela Cruz']);
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $types = [
        NotificationType::Arrival,
        NotificationType::Late,
        NotificationType::Departure,
        NotificationType::Absence,
        NotificationType::Correction,
    ];

    foreach ($types as $index => $type) {
        $summary = AttendanceDailySummary::factory()->for($student)->create([
            'date' => now()->addDays($index)->toDateString(),
        ]);
        app(NotifyGuardiansOfAttendanceEvent::class)($summary, $type);
    }

    $titles = GuardianNotification::query()->pluck('title')->unique();
    expect($titles)->toHaveCount(5);
    expect(GuardianNotification::query()->where('type', NotificationType::Correction)->firstOrFail()->body)
        ->not->toContain('reason');
});

test('an announcement-published type is rejected', function () {
    $student = Student::factory()->create();
    $summary = AttendanceDailySummary::factory()->for($student)->create();

    expect(fn () => app(NotifyGuardiansOfAttendanceEvent::class)($summary, NotificationType::AnnouncementPublished))
        ->toThrow(InvalidArgumentException::class);
});
