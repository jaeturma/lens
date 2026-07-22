<?php

use App\Actions\Announcements\PublishAnnouncement;
use App\Actions\Attendance\ProcessRfidScan;
use App\Actions\RfidCards\AssignRfidCard;
use App\Enums\AnnouncementAudienceType;
use App\Enums\AnnouncementStatus;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidScanClassification;
use App\Models\Announcement;
use App\Models\AttendanceDailySummary;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\Student;
use App\Models\User;

test('bootstrap returns the school profile, user, and a usable cursor', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk()->assertJson([
        'success' => true,
        'data' => [
            'school' => ['school_id' => 'SCH-0001'],
            'user' => ['id' => $user->id, 'email' => $user->email],
        ],
    ]);

    expect($response->json('data.next_cursor'))->toBeString()->not->toBeEmpty();
});

test('bootstrap returns null guardian and empty children when there is no profile yet', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk()->assertJson([
        'data' => ['guardian' => null, 'children' => []],
    ]);
});

test('bootstrap returns the guardian profile and only actively linked children', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();

    $activeStudent = Student::factory()->create();
    $revokedStudent = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($activeStudent)->create([
        'status' => GuardianStudentLinkStatus::Active,
        'relationship_type' => 'mother',
    ]);
    GuardianStudentLink::factory()->for($guardian)->for($revokedStudent)->create([
        'status' => GuardianStudentLinkStatus::Revoked,
    ]);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk()->assertJson([
        'data' => [
            'guardian' => ['uuid' => $guardian->uuid, 'email' => $guardian->email],
        ],
    ]);

    $children = $response->json('data.children');
    expect($children)->toHaveCount(1);
    expect($children[0]['uuid'])->toBe($activeStudent->uuid);
    expect($children[0]['relationship_type'])->toBe('mother');
});

test('bootstrap reports null today_attendance for a child with no summary today', function () {
    bindSchool(['timezone' => 'UTC']);
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk();
    expect($response->json('data.children.0.today_attendance'))->toBeNull();
});

test('bootstrap reports today\'s attendance for a child who arrived today', function () {
    bindSchool(['timezone' => 'UTC']);
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $device = RfidDevice::factory()->create(['direction_mode' => RfidDeviceDirectionMode::Entry]);
    $uid = 'BOOTATT1';
    app(AssignRfidCard::class)($student, $uid);
    $scan = RfidScan::factory()->for($device, 'device')->create([
        'uid' => $uid,
        'classification' => RfidScanClassification::Valid,
    ]);
    $event = (new ProcessRfidScan)($scan);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk();
    $attendance = $response->json('data.children.0.today_attendance');
    expect($attendance)->not->toBeNull();
    expect($attendance['arrival'])->toBe($event->occurred_at->toIso8601String());
    expect($attendance['departure'])->toBeNull();
    expect($attendance['is_absent'])->toBeFalse();
});

test('bootstrap does not report yesterday\'s attendance as today_attendance', function () {
    bindSchool(['timezone' => 'UTC']);
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    AttendanceDailySummary::factory()->for($student)->create(['date' => now()->subDay()->toDateString()]);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk();
    expect($response->json('data.children.0.today_attendance'))->toBeNull();
});

test('bootstrap includes a published announcement matching the guardian\'s audience', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create(['audience_type' => AnnouncementAudienceType::All]);
    (new PublishAnnouncement)($announcement);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk();
    $announcements = $response->json('data.announcements');
    expect($announcements)->toHaveCount(1);
    expect($announcements[0]['uuid'])->toBe($announcement->uuid);
});

test('bootstrap excludes a published announcement that does not match the guardian\'s audience', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create(['grade' => 'Grade 8']);
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $announcement = Announcement::factory()->create([
        'audience_type' => AnnouncementAudienceType::Grade,
        'audience_grade' => 'Grade 7',
    ]);
    (new PublishAnnouncement)($announcement);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk();
    expect($response->json('data.announcements'))->toBeEmpty();
});

test('bootstrap excludes draft, withdrawn, and expired announcements', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;
    $guardian = Guardian::factory()->for($user)->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    Announcement::factory()->create(['status' => AnnouncementStatus::Draft, 'audience_type' => AnnouncementAudienceType::All]);
    Announcement::factory()->create(['status' => AnnouncementStatus::Withdrawn, 'audience_type' => AnnouncementAudienceType::All]);
    Announcement::factory()->create(['status' => AnnouncementStatus::Expired, 'audience_type' => AnnouncementAudienceType::All]);

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertOk();
    expect($response->json('data.announcements'))->toBeEmpty();
});

test('an unauthenticated bootstrap request is rejected', function () {
    bindSchool();

    $response = $this->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a non-guardian account is rejected from bootstrap', function () {
    bindSchool();
    $user = User::factory()->schoolAdministrator()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(403)->assertJson(['success' => false]);
});

test('bootstrap is rejected while the school is in maintenance mode', function () {
    bindSchool(['maintenance_mode' => true, 'maintenance_message' => 'Back soon.']);
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withToken($token)->getJson('/api/v1/sync/bootstrap');

    $response->assertStatus(503)->assertJson(['success' => false, 'message' => 'Back soon.']);
});

test('the bootstrap endpoint is rate limited', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    for ($i = 0; $i < 30; $i++) {
        $this->withToken($token)->getJson('/api/v1/sync/bootstrap')->assertOk();
    }

    $this->withToken($token)->getJson('/api/v1/sync/bootstrap')->assertStatus(429);
});
