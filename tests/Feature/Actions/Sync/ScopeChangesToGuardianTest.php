<?php

use App\Actions\Announcements\PublishAnnouncement;
use App\Actions\Sync\RecordSyncChange;
use App\Actions\Sync\ScopeChangesToGuardian;
use App\Enums\AnnouncementAudienceType;
use App\Enums\AnnouncementStatus;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\SyncChangeAction;
use App\Models\Announcement;
use App\Models\AttendanceDailySummary;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\School;
use App\Models\Student;
use App\Models\SyncChange;
use Illuminate\Support\Collection;

test('school changes are visible to every guardian, including one with no profile', function () {
    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Updated);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), null);

    expect($scoped)->toHaveCount(1);
});

test('student changes are visible only for currently active links', function () {
    $guardian = Guardian::factory()->create();
    $linkedStudent = Student::factory()->create();
    $unlinkedStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($linkedStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    $linkedChange = (new RecordSyncChange)($linkedStudent, SyncChangeAction::Updated);
    $unlinkedChange = (new RecordSyncChange)($unlinkedStudent, SyncChangeAction::Updated);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$linkedChange, $unlinkedChange]), $guardian);

    expect($scoped->pluck('id')->all())->toBe([$linkedChange->id]);
});

test('student changes for a revoked link are not visible', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $change = (new RecordSyncChange)($student, SyncChangeAction::Updated);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian);

    expect($scoped)->toBeEmpty();
});

test('a guardian_student_link change is visible even after that link is revoked', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $change = (new RecordSyncChange)($link, SyncChangeAction::Revoked);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian);

    expect($scoped)->toHaveCount(1);
});

test('a guardian_student_link change for another guardian is not visible', function () {
    $guardian = Guardian::factory()->create();
    $otherGuardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $otherLink = GuardianStudentLink::factory()->for($otherGuardian)->for($student)->create();

    $change = (new RecordSyncChange)($otherLink, SyncChangeAction::Created);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian);

    expect($scoped)->toBeEmpty();
});

test('guardian changes are visible only for the guardian\'s own record', function () {
    $guardian = Guardian::factory()->create();
    $otherGuardian = Guardian::factory()->create();

    $ownChange = (new RecordSyncChange)($guardian, SyncChangeAction::Updated);
    $otherChange = (new RecordSyncChange)($otherGuardian, SyncChangeAction::Updated);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$ownChange, $otherChange]), $guardian);

    expect($scoped->pluck('id')->all())->toBe([$ownChange->id]);
});

test('a guardian with no profile sees no student, guardian, or link changes', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create();

    $studentChange = (new RecordSyncChange)($student, SyncChangeAction::Updated);
    $guardianChange = (new RecordSyncChange)($guardian, SyncChangeAction::Updated);
    $linkChange = (new RecordSyncChange)($link, SyncChangeAction::Updated);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$studentChange, $guardianChange, $linkChange]), null);

    expect($scoped)->toBeEmpty();
});

test('attendance daily summary changes are visible only for currently active links, scoped by the payload student_id', function () {
    $guardian = Guardian::factory()->create();
    $linkedStudent = Student::factory()->create();
    $unlinkedStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($linkedStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    $linkedSummary = AttendanceDailySummary::factory()->for($linkedStudent)->create();
    $unlinkedSummary = AttendanceDailySummary::factory()->for($unlinkedStudent)->create();

    $linkedChange = (new RecordSyncChange)($linkedSummary, SyncChangeAction::Updated, ['student_id' => $linkedStudent->id]);
    $unlinkedChange = (new RecordSyncChange)($unlinkedSummary, SyncChangeAction::Updated, ['student_id' => $unlinkedStudent->id]);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$linkedChange, $unlinkedChange]), $guardian);

    expect($scoped->pluck('id')->all())->toBe([$linkedChange->id]);
});

test('attendance daily summary changes for a revoked link are not visible', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);
    $summary = AttendanceDailySummary::factory()->for($student)->create();

    $change = (new RecordSyncChange)($summary, SyncChangeAction::Corrected, ['student_id' => $student->id]);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian);

    expect($scoped)->toBeEmpty();
});

test('an announcement change is visible to a guardian whose active student matches the audience', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create(['grade' => 'Grade 7']);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);
    (new PublishAnnouncement)($announcement);

    $change = SyncChange::query()->where('resource_type', 'announcement')->where('resource_id', $announcement->id)->firstOrFail();

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian);

    expect($scoped)->toHaveCount(1);
});

test('an announcement change is not visible to a guardian whose student does not match the audience', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create(['grade' => 'Grade 8']);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);
    (new PublishAnnouncement)($announcement);

    $change = SyncChange::query()->where('resource_type', 'announcement')->where('resource_id', $announcement->id)->firstOrFail();

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian);

    expect($scoped)->toBeEmpty();
});

test('an announcement change is not visible once the matching link is revoked', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft, 'audience_type' => AnnouncementAudienceType::All]);
    (new PublishAnnouncement)($announcement);
    $change = SyncChange::query()->where('resource_type', 'announcement')->where('resource_id', $announcement->id)->firstOrFail();

    $link->update(['status' => GuardianStudentLinkStatus::Revoked]);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), $guardian->fresh());

    expect($scoped)->toBeEmpty();
});

test('an announcement change with no guardian is never visible', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft, 'audience_type' => AnnouncementAudienceType::All]);
    (new PublishAnnouncement)($announcement);
    $change = SyncChange::query()->where('resource_type', 'announcement')->where('resource_id', $announcement->id)->firstOrFail();

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), null);

    expect($scoped)->toBeEmpty();
});

test('an unrecognized resource type is denied by default', function () {
    $change = SyncChange::factory()->create(['resource_type' => 'something_new']);

    $scoped = app(ScopeChangesToGuardian::class)(new Collection([$change]), null);

    expect($scoped)->toBeEmpty();
});
