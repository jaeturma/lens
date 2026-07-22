<?php

use App\Actions\Announcements\GuardianMatchesAnnouncementAudience;
use App\Enums\AnnouncementAudienceType;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\StudentStatus;
use App\Models\Announcement;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\Student;

test('a guardian matches an all-guardians announcement through any active linked student', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create(['status' => StudentStatus::Active]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    $matches = app(GuardianMatchesAnnouncementAudience::class)($announcement, $guardian);

    expect($matches)->toBeTrue();
});

test('a guardian with no linked students does not match an all-guardians announcement', function () {
    $guardian = Guardian::factory()->create();
    Student::factory()->create(['status' => StudentStatus::Active]);
    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    $matches = app(GuardianMatchesAnnouncementAudience::class)($announcement, $guardian);

    expect($matches)->toBeFalse();
});

test('a guardian matches a grade-targeted announcement only through a student in that grade', function () {
    $guardian = Guardian::factory()->create();
    $matchingStudent = Student::factory()->create(['status' => StudentStatus::Active, 'grade' => 'Grade 7']);
    GuardianStudentLink::factory()->for($guardian)->for($matchingStudent)->create(['status' => GuardianStudentLinkStatus::Active]);
    $announcement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);

    expect(app(GuardianMatchesAnnouncementAudience::class)($announcement, $guardian))->toBeTrue();

    $otherAnnouncement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 8',
    ]);

    expect(app(GuardianMatchesAnnouncementAudience::class)($otherAnnouncement, $guardian))->toBeFalse();
});

test('a guardian matches a students-targeted announcement only if their student was selected', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create(['status' => StudentStatus::Active]);
    $otherStudent = Student::factory()->create(['status' => StudentStatus::Active]);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::Students]);
    $announcement->students()->sync([$otherStudent->id]);

    expect(app(GuardianMatchesAnnouncementAudience::class)($announcement, $guardian))->toBeFalse();

    $announcement->students()->sync([$student->id]);

    expect(app(GuardianMatchesAnnouncementAudience::class)($announcement->fresh(), $guardian))->toBeTrue();
});

test('revoking a link stops the guardian from matching immediately', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create(['status' => StudentStatus::Active]);
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);
    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    expect(app(GuardianMatchesAnnouncementAudience::class)($announcement, $guardian))->toBeTrue();

    $link->update(['status' => GuardianStudentLinkStatus::Revoked]);

    expect(app(GuardianMatchesAnnouncementAudience::class)($announcement, $guardian->fresh()))->toBeFalse();
});
