<?php

use App\Actions\Announcements\ResolveAnnouncementAudience;
use App\Enums\AnnouncementAudienceType;
use App\Enums\StudentStatus;
use App\Models\Announcement;
use App\Models\Student;

test('an all-guardians audience resolves to every active student', function () {
    $active = Student::factory()->count(2)->create(['status' => StudentStatus::Active]);
    Student::factory()->create(['status' => StudentStatus::Inactive]);
    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);

    $resolved = (new ResolveAnnouncementAudience)($announcement);

    expect($resolved->sort()->values()->all())->toBe($active->pluck('id')->sort()->values()->all());
});

test('a grade audience resolves to active students in that grade only', function () {
    $matching = Student::factory()->create(['status' => StudentStatus::Active, 'grade' => 'Grade 7']);
    Student::factory()->create(['status' => StudentStatus::Active, 'grade' => 'Grade 8']);
    Student::factory()->create(['status' => StudentStatus::Inactive, 'grade' => 'Grade 7']);
    $announcement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);

    $resolved = (new ResolveAnnouncementAudience)($announcement);

    expect($resolved->all())->toBe([$matching->id]);
});

test('a section audience resolves to active students in that grade and section only', function () {
    $matching = Student::factory()->create(['status' => StudentStatus::Active, 'grade' => 'Grade 7', 'section' => 'Diamond']);
    Student::factory()->create(['status' => StudentStatus::Active, 'grade' => 'Grade 7', 'section' => 'Emerald']);
    Student::factory()->create(['status' => StudentStatus::Active, 'grade' => 'Grade 8', 'section' => 'Diamond']);
    $announcement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Section,
        'audience_grade' => 'Grade 7',
        'audience_section' => 'Diamond',
    ]);

    $resolved = (new ResolveAnnouncementAudience)($announcement);

    expect($resolved->all())->toBe([$matching->id]);
});

test('a students audience resolves to only the active selected students', function () {
    $selectedActive = Student::factory()->create(['status' => StudentStatus::Active]);
    $selectedInactive = Student::factory()->create(['status' => StudentStatus::Inactive]);
    $notSelected = Student::factory()->create(['status' => StudentStatus::Active]);
    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::Students]);
    $announcement->students()->sync([$selectedActive->id, $selectedInactive->id]);

    $resolved = (new ResolveAnnouncementAudience)($announcement);

    expect($resolved->all())->toBe([$selectedActive->id]);
    expect($resolved->all())->not->toContain($notSelected->id);
});
