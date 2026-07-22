<?php

use App\Actions\Notifications\NotifyGuardiansOfAnnouncement;
use App\Enums\AnnouncementAudienceType;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\NotificationType;
use App\Models\Announcement;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;
use App\Models\Student;

test('every active, notify_announcements-enabled matching guardian gets their own notification', function () {
    $student = Student::factory()->create();
    $notifying = Guardian::factory()->create(['notify_announcements' => true]);
    $optedOut = Guardian::factory()->create(['notify_announcements' => false]);
    $revoked = Guardian::factory()->create(['notify_announcements' => true]);
    GuardianStudentLink::factory()->for($notifying)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    GuardianStudentLink::factory()->for($optedOut)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    GuardianStudentLink::factory()->for($revoked)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    app(NotifyGuardiansOfAnnouncement::class)($announcement);

    expect(GuardianNotification::query()->count())->toBe(1);
    $notification = GuardianNotification::query()->firstOrFail();
    expect($notification->guardian_id)->toBe($notifying->id);
    expect($notification->type)->toBe(NotificationType::AnnouncementPublished);
    expect($notification->title)->toBe($announcement->title);
    expect($notification->body)->toBe($announcement->body);
});

test('a guardian with two matching children still gets exactly one notification', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $studentA = Student::factory()->create();
    $studentB = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($studentA)->create(['status' => GuardianStudentLinkStatus::Active]);
    GuardianStudentLink::factory()->for($guardian)->for($studentB)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    app(NotifyGuardiansOfAnnouncement::class)($announcement);

    expect(GuardianNotification::query()->count())->toBe(1);
});

test('a guardian whose student does not match the audience receives nothing', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create(['grade' => 'Grade 8']);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);

    app(NotifyGuardiansOfAnnouncement::class)($announcement);

    expect(GuardianNotification::query()->count())->toBe(0);
});

test('the notification payload references the announcement', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    app(NotifyGuardiansOfAnnouncement::class)($announcement);

    $notification = GuardianNotification::query()->firstOrFail();
    expect($notification->payload)->toBe([
        'announcement_id' => $announcement->id,
        'announcement_uuid' => $announcement->uuid,
    ]);
});
