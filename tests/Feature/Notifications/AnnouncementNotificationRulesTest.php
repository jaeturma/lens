<?php

use App\Actions\Announcements\PublishAnnouncement;
use App\Actions\Announcements\WithdrawAnnouncement;
use App\Enums\AnnouncementAudienceType;
use App\Enums\AnnouncementStatus;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\NotificationType;
use App\Models\Announcement;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;
use App\Models\Student;

test('publishing a draft notifies the matching, opted-in guardian', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::All,
    ]);

    (new PublishAnnouncement)($announcement);

    expect(GuardianNotification::query()->count())->toBe(1);
    expect(GuardianNotification::query()->firstOrFail()->type)->toBe(NotificationType::AnnouncementPublished);
});

test('drafts never notify — creating one, or editing it, sends nothing', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::All,
    ]);
    $announcement->update(['title' => 'Edited while still a draft']);

    expect(GuardianNotification::query()->count())->toBe(0);
});

test('editing a published announcement does not send a new round of notifications', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $newlyMatchingGuardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create(['grade' => 'Grade 7']);
    $newlyMatchingStudent = Student::factory()->create(['grade' => 'Grade 8']);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    GuardianStudentLink::factory()->for($newlyMatchingGuardian)->for($newlyMatchingStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);
    (new PublishAnnouncement)($announcement);
    expect(GuardianNotification::query()->count())->toBe(1);

    // "Republish" behavior: widening the audience after publish does not
    // backfill a notification to the newly-matching guardian.
    $announcement->update(['audience_grade' => 'Grade 8', 'title' => 'Updated title']);

    expect(GuardianNotification::query()->count())->toBe(1);
    expect(GuardianNotification::query()->where('guardian_id', $newlyMatchingGuardian->id)->count())->toBe(0);
});

test('withdrawing or expiring an announcement does not notify', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::All,
    ]);
    (new PublishAnnouncement)($announcement);
    expect(GuardianNotification::query()->count())->toBe(1);

    (new WithdrawAnnouncement)($announcement);

    expect(GuardianNotification::query()->count())->toBe(1);
});

test('a directly-created published announcement still notifies', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => true]);
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    Announcement::factory()->create([
        'status' => AnnouncementStatus::Published,
        'published_at' => now(),
        'audience_type' => AnnouncementAudienceType::All,
    ]);

    expect(GuardianNotification::query()->count())->toBe(1);
});

test('a guardian who opted out of announcement notifications receives none', function () {
    $guardian = Guardian::factory()->create(['notify_announcements' => false]);
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::All,
    ]);

    (new PublishAnnouncement)($announcement);

    expect(GuardianNotification::query()->count())->toBe(0);
});
