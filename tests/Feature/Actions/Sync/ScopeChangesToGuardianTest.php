<?php

use App\Actions\Sync\RecordSyncChange;
use App\Actions\Sync\ScopeChangesToGuardian;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\SyncChangeAction;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\School;
use App\Models\Student;
use App\Models\SyncChange;
use Illuminate\Support\Collection;

test('school changes are visible to every guardian, including one with no profile', function () {
    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Updated);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$change]), null);

    expect($scoped)->toHaveCount(1);
});

test('student changes are visible only for currently active links', function () {
    $guardian = Guardian::factory()->create();
    $linkedStudent = Student::factory()->create();
    $unlinkedStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($linkedStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    $linkedChange = (new RecordSyncChange)($linkedStudent, SyncChangeAction::Updated);
    $unlinkedChange = (new RecordSyncChange)($unlinkedStudent, SyncChangeAction::Updated);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$linkedChange, $unlinkedChange]), $guardian);

    expect($scoped->pluck('id')->all())->toBe([$linkedChange->id]);
});

test('student changes for a revoked link are not visible', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $change = (new RecordSyncChange)($student, SyncChangeAction::Updated);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$change]), $guardian);

    expect($scoped)->toBeEmpty();
});

test('a guardian_student_link change is visible even after that link is revoked', function () {
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $change = (new RecordSyncChange)($link, SyncChangeAction::Revoked);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$change]), $guardian);

    expect($scoped)->toHaveCount(1);
});

test('a guardian_student_link change for another guardian is not visible', function () {
    $guardian = Guardian::factory()->create();
    $otherGuardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $otherLink = GuardianStudentLink::factory()->for($otherGuardian)->for($student)->create();

    $change = (new RecordSyncChange)($otherLink, SyncChangeAction::Created);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$change]), $guardian);

    expect($scoped)->toBeEmpty();
});

test('guardian changes are visible only for the guardian\'s own record', function () {
    $guardian = Guardian::factory()->create();
    $otherGuardian = Guardian::factory()->create();

    $ownChange = (new RecordSyncChange)($guardian, SyncChangeAction::Updated);
    $otherChange = (new RecordSyncChange)($otherGuardian, SyncChangeAction::Updated);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$ownChange, $otherChange]), $guardian);

    expect($scoped->pluck('id')->all())->toBe([$ownChange->id]);
});

test('a guardian with no profile sees no student, guardian, or link changes', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create();

    $studentChange = (new RecordSyncChange)($student, SyncChangeAction::Updated);
    $guardianChange = (new RecordSyncChange)($guardian, SyncChangeAction::Updated);
    $linkChange = (new RecordSyncChange)($link, SyncChangeAction::Updated);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$studentChange, $guardianChange, $linkChange]), null);

    expect($scoped)->toBeEmpty();
});

test('an unrecognized resource type is denied by default', function () {
    $change = SyncChange::factory()->create(['resource_type' => 'something_new']);

    $scoped = (new ScopeChangesToGuardian)(new Collection([$change]), null);

    expect($scoped)->toBeEmpty();
});
