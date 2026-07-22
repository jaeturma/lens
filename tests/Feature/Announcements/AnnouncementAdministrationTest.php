<?php

use App\Enums\AnnouncementAudienceType;
use App\Enums\AnnouncementStatus;
use App\Enums\StudentStatus;
use App\Models\Announcement;
use App\Models\Student;
use App\Models\User;

test('a guardian is rejected from every announcements route', function () {
    $guardian = User::factory()->create();
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Published, 'published_at' => now()]);

    $this->actingAs($guardian)->get(route('announcements.index'))->assertForbidden();
    $this->actingAs($guardian)->get(route('announcements.create'))->assertForbidden();
    $this->actingAs($guardian)->post(route('announcements.store'), [])->assertForbidden();
    $this->actingAs($guardian)->get(route('announcements.show', $announcement))->assertForbidden();
    $this->actingAs($guardian)->get(route('announcements.edit', $announcement))->assertForbidden();
    $this->actingAs($guardian)->put(route('announcements.update', $announcement), [])->assertForbidden();
    $this->actingAs($guardian)->patch(route('announcements.publish', $announcement))->assertForbidden();
    $this->actingAs($guardian)->patch(route('announcements.withdraw', $announcement))->assertForbidden();
    $this->actingAs($guardian)->patch(route('announcements.expire', $announcement))->assertForbidden();
});

test('an administrator can view, search, and filter the announcements index', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    Announcement::factory()->create(['title' => 'Foundation Day', 'status' => AnnouncementStatus::Draft]);
    Announcement::factory()->create(['title' => 'Something Else', 'status' => AnnouncementStatus::Draft]);

    $this->actingAs($admin)->get(route('announcements.index'))->assertOk();

    $response = $this->actingAs($admin)->get(route('announcements.index', ['q' => 'Foundation']));

    $response->assertInertia(fn ($page) => $page->has('announcements.data', 1));
});

test('an administrator can create a draft announcement', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('announcements.store'), [
        'title' => 'Foundation Day',
        'body' => 'School closed for Foundation Day celebrations.',
        'audience_type' => 'all',
    ]);

    $announcement = Announcement::query()->where('title', 'Foundation Day')->firstOrFail();
    $response->assertRedirect(route('announcements.show', $announcement));
    expect($announcement->status)->toBe(AnnouncementStatus::Draft);
    expect($announcement->author_id)->toBe($admin->id);
    expect($announcement->audience_type)->toBe(AnnouncementAudienceType::All);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'announcement.created',
        'target_type' => 'announcement',
        'target_id' => $announcement->id,
    ]);
});

test('creating an announcement requires a title and body', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('announcements.store'), []);

    $response->assertSessionHasErrors(['title', 'body']);
    expect(Announcement::query()->count())->toBe(0);
});

test('an administrator can update an announcement\'s title and body', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $announcement = Announcement::factory()->create(['title' => 'Old Title']);

    $response = $this->actingAs($admin)->put(route('announcements.update', $announcement), [
        'title' => 'New Title',
        'body' => 'Updated body text.',
        'audience_type' => 'all',
    ]);

    $response->assertRedirect(route('announcements.show', $announcement));
    expect($announcement->fresh()->title)->toBe('New Title');

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'announcement.updated',
        'target_id' => $announcement->id,
    ]);
});

test('an administrator can publish, then withdraw, an announcement', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    $this->actingAs($admin)->patch(route('announcements.publish', $announcement))->assertRedirect();
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Published);
    $this->assertDatabaseHas('audit_logs', ['action' => 'announcement.published', 'target_id' => $announcement->id]);

    $this->actingAs($admin)->patch(route('announcements.withdraw', $announcement))->assertRedirect();
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Withdrawn);
    $this->assertDatabaseHas('audit_logs', ['action' => 'announcement.withdrawn', 'target_id' => $announcement->id]);
});

test('an administrator can manually expire a published announcement', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Published, 'published_at' => now()]);

    $response = $this->actingAs($admin)->patch(route('announcements.expire', $announcement));

    $response->assertRedirect();
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Expired);
    $this->assertDatabaseHas('audit_logs', ['action' => 'announcement.expired', 'target_id' => $announcement->id]);
});

test('publishing an already-published announcement is rejected with a validation error', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Published, 'published_at' => now()]);

    $response = $this->actingAs($admin)->patch(route('announcements.publish', $announcement));

    $response->assertSessionHasErrors('status');
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Published);
});

test('withdrawing a draft is rejected with a validation error', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    $response = $this->actingAs($admin)->patch(route('announcements.withdraw', $announcement));

    $response->assertSessionHasErrors('status');
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Draft);
});

test('an administrator can create a grade-targeted announcement', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('announcements.store'), [
        'title' => 'Grade 7 Assembly',
        'body' => 'Grade 7 students report to the covered court.',
        'audience_type' => 'grade',
        'audience_grade' => 'Grade 7',
    ]);

    $announcement = Announcement::query()->where('title', 'Grade 7 Assembly')->firstOrFail();
    $response->assertRedirect(route('announcements.show', $announcement));
    expect($announcement->audience_type)->toBe(AnnouncementAudienceType::Grade);
    expect($announcement->audience_grade)->toBe('Grade 7');
});

test('creating a grade-targeted announcement without a grade is rejected', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('announcements.store'), [
        'title' => 'Grade 7 Assembly',
        'body' => 'Grade 7 students report to the covered court.',
        'audience_type' => 'grade',
    ]);

    $response->assertSessionHasErrors('audience_grade');
});

test('creating a section-targeted announcement without a section is rejected', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('announcements.store'), [
        'title' => 'Diamond Section Notice',
        'body' => 'Section-specific notice.',
        'audience_type' => 'section',
        'audience_grade' => 'Grade 7',
    ]);

    $response->assertSessionHasErrors('audience_section');
});

test('an administrator can create a students-targeted announcement and it round-trips on edit', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create(['status' => StudentStatus::Active]);

    $response = $this->actingAs($admin)->post(route('announcements.store'), [
        'title' => 'Personal Notice',
        'body' => 'Please see the guidance office.',
        'audience_type' => 'students',
        'student_ids' => [$student->id],
    ]);

    $announcement = Announcement::query()->where('title', 'Personal Notice')->firstOrFail();
    $response->assertRedirect(route('announcements.show', $announcement));
    expect($announcement->audience_type)->toBe(AnnouncementAudienceType::Students);
    expect($announcement->students()->pluck('students.id')->all())->toBe([$student->id]);

    $edit = $this->actingAs($admin)->get(route('announcements.edit', $announcement));
    $edit->assertInertia(fn ($page) => $page
        ->where('announcement.students.0.id', $student->id));
});

test('creating a students-targeted announcement without any students is rejected', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('announcements.store'), [
        'title' => 'Personal Notice',
        'body' => 'Please see the guidance office.',
        'audience_type' => 'students',
    ]);

    $response->assertSessionHasErrors('student_ids');
});
