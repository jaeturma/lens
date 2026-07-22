<?php

use App\Actions\Announcements\PublishAnnouncement;
use App\Actions\Announcements\WithdrawAnnouncement;
use App\Actions\Sync\RecordSyncChange;
use App\Enums\AnnouncementAudienceType;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\SyncChangeAction;
use App\Models\Announcement;
use App\Models\AttendanceDailySummary;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\School;
use App\Models\Student;
use App\Models\SyncChange;
use App\Models\User;
use App\Support\Sync\SyncCursor;

function syncChangesUri(string $cursor, ?int $limit = null): string
{
    $query = array_filter(['cursor' => $cursor, 'limit' => $limit], fn ($value) => $value !== null);

    return '/api/v1/sync/changes?'.http_build_query($query);
}

test('incremental sync returns changes after the given cursor', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Updated, ['name' => 'New Name']);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial()));

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'has_more' => false,
            'changes' => [
                [
                    'resource_type' => $school->getMorphClass(),
                    'resource_id' => $school->id,
                    'action' => 'updated',
                    'payload' => ['name' => 'New Name'],
                ],
            ],
        ],
    ]);

    expect($response->json('data.next_cursor'))->toBe((string) SyncCursor::fromSequence($change->id));
});

test('a cursor at the current tip returns no changes and leaves the cursor unchanged', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $school = School::factory()->create();
    $change = (new RecordSyncChange)($school, SyncChangeAction::Created);
    $cursor = SyncCursor::fromSequence($change->id);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursor));

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => ['has_more' => false, 'changes' => []],
    ]);
    expect($response->json('data.next_cursor'))->toBe((string) $cursor);
});

test('a request without a cursor is rejected', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/changes');

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('a malformed cursor is rejected', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson(syncChangesUri('not-a-cursor'));

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('a limit beyond 200 is rejected', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial(), 201));

    $response->assertStatus(422)->assertJson(['success' => false]);
});

test('results are chunked by limit and report has_more', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $school = School::factory()->create();
    for ($i = 0; $i < 3; $i++) {
        (new RecordSyncChange)($school, SyncChangeAction::Updated);
    }

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial(), 2));

    $response->assertOk()->assertJson(['data' => ['has_more' => true]]);
    expect($response->json('data.changes'))->toHaveCount(2);
});

test('incremental sync only returns student changes for the guardian\'s own active links', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();

    $ownStudent = Student::factory()->create();
    $otherStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($ownStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    // Capture the cursor after setup so only the two explicit changes below are asserted on;
    // creating the guardian/students/link above already produced their own (correctly-visible) entries.
    $cursorAfterSetup = SyncCursor::fromSequence((int) SyncChange::query()->max('id'));

    (new RecordSyncChange)($ownStudent, SyncChangeAction::Updated);
    (new RecordSyncChange)($otherStudent, SyncChangeAction::Updated);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursorAfterSetup));

    $response->assertOk();
    $changes = $response->json('data.changes');
    expect($changes)->toHaveCount(1);
    expect($changes[0]['resource_id'])->toBe($ownStudent->id);
});

test('incremental sync returns a link revocation even after the link is no longer active', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $cursorAfterSetup = SyncCursor::fromSequence((int) SyncChange::query()->max('id'));

    (new RecordSyncChange)($link, SyncChangeAction::Revoked);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursorAfterSetup));

    $response->assertOk();
    $changes = $response->json('data.changes');
    expect($changes)->toHaveCount(1);
    expect($changes[0]['resource_type'])->toBe('guardian_student_link');
    expect($changes[0]['action'])->toBe('revoked');
});

test('incremental sync only returns attendance changes for the guardian\'s own active links', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();

    $ownStudent = Student::factory()->create();
    $otherStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($ownStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    $ownSummary = AttendanceDailySummary::factory()->for($ownStudent)->create();
    $otherSummary = AttendanceDailySummary::factory()->for($otherStudent)->create();

    $cursorAfterSetup = SyncCursor::fromSequence((int) SyncChange::query()->max('id'));

    (new RecordSyncChange)($ownSummary, SyncChangeAction::Updated, ['student_id' => $ownStudent->id]);
    (new RecordSyncChange)($otherSummary, SyncChangeAction::Updated, ['student_id' => $otherStudent->id]);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursorAfterSetup));

    $response->assertOk();
    $changes = $response->json('data.changes');
    expect($changes)->toHaveCount(1);
    expect($changes[0]['resource_id'])->toBe($ownSummary->id);
});

test('incremental sync only returns announcement changes matching the guardian\'s audience', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $matchingStudent = Student::factory()->create(['grade' => 'Grade 7']);
    GuardianStudentLink::factory()->for($guardian)->for($matchingStudent)->create(['status' => GuardianStudentLinkStatus::Active]);

    $cursorAfterSetup = SyncCursor::fromSequence((int) SyncChange::query()->max('id'));

    $matchingAnnouncement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);
    (new PublishAnnouncement)($matchingAnnouncement);

    $nonMatchingAnnouncement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 8',
    ]);
    (new PublishAnnouncement)($nonMatchingAnnouncement);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursorAfterSetup));

    $response->assertOk();
    $changes = $response->json('data.changes');
    expect($changes)->toHaveCount(1);
    expect($changes[0]['resource_id'])->toBe($matchingAnnouncement->id);
    expect($changes[0]['action'])->toBe('created');
});

test('withdrawing an announcement synchronizes as revoked to a matching guardian', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);
    (new PublishAnnouncement)($announcement);

    $cursorAfterSetup = SyncCursor::fromSequence((int) SyncChange::query()->max('id'));

    (new WithdrawAnnouncement)($announcement);

    $response = $this->withToken($token)->getJson(syncChangesUri((string) $cursorAfterSetup));

    $response->assertOk();
    $changes = $response->json('data.changes');
    expect($changes)->toHaveCount(1);
    expect($changes[0]['resource_type'])->toBe('announcement');
    expect($changes[0]['action'])->toBe('revoked');
});

test('a non-guardian account is rejected from incremental sync', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson(syncChangesUri((string) SyncCursor::initial()));

    $response->assertStatus(403)->assertJson(['success' => false]);
});
