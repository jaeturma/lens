<?php

use App\Enums\GuardianStatus;
use App\Enums\GuardianStudentLinkStatus;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\Student;
use App\Models\User;

test('a guardian is rejected from every guardians route', function () {
    $actor = User::factory()->create();
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create();

    $this->actingAs($actor)->get(route('guardians.index'))->assertForbidden();
    $this->actingAs($actor)->get(route('guardians.create'))->assertForbidden();
    $this->actingAs($actor)->post(route('guardians.store'), [])->assertForbidden();
    $this->actingAs($actor)->get(route('guardians.show', $guardian))->assertForbidden();
    $this->actingAs($actor)->get(route('guardians.edit', $guardian))->assertForbidden();
    $this->actingAs($actor)->put(route('guardians.update', $guardian), [])->assertForbidden();
    $this->actingAs($actor)->patch(route('guardians.activate', $guardian))->assertForbidden();
    $this->actingAs($actor)->patch(route('guardians.deactivate', $guardian))->assertForbidden();
    $this->actingAs($actor)->post(route('guardians.links.store', $guardian), [])->assertForbidden();
    $this->actingAs($actor)->patch(route('guardians.links.revoke', [$guardian, $link]))->assertForbidden();
});

test('an administrator can view, search, and filter the guardians index', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $match = Guardian::factory()->create(['name' => 'Maria Dela Cruz', 'status' => GuardianStatus::Active]);
    Guardian::factory()->create(['name' => 'Someone Else', 'status' => GuardianStatus::Inactive]);

    $this->actingAs($admin)->get(route('guardians.index'))->assertOk();

    $response = $this->actingAs($admin)->get(route('guardians.index', ['q' => 'Dela Cruz', 'status' => 'active']));

    $response->assertInertia(fn ($page) => $page
        ->has('guardians.data', 1)
        ->where('guardians.data.0.id', $match->id)
    );
});

test('an administrator can create a guardian account', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('guardians.store'), [
        'name' => 'Maria Dela Cruz',
        'email' => 'maria@example.com',
        'password' => 'correct-password-123',
        'password_confirmation' => 'correct-password-123',
        'mobile_number' => '09171234567',
    ]);

    $user = User::query()->where('email', 'maria@example.com')->firstOrFail();
    $guardian = Guardian::query()->where('user_id', $user->id)->firstOrFail();

    $response->assertRedirect(route('guardians.show', $guardian));
    expect($user->isGuardian())->toBeTrue();
    expect($guardian->status)->toBe(GuardianStatus::Active);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'guardian.created',
        'target_type' => 'guardian',
        'target_id' => $guardian->id,
    ]);
});

test('creating a guardian validates required fields and unique email', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $existing = User::factory()->create();

    $response = $this->actingAs($admin)->post(route('guardians.store'), [
        'email' => $existing->email,
    ]);

    $response->assertSessionHasErrors(['name', 'email', 'password', 'mobile_number']);
    expect(Guardian::query()->count())->toBe(0);
});

test('an administrator can view a guardian with their links', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create();

    $response = $this->actingAs($admin)->get(route('guardians.show', $guardian));

    $response->assertOk();
    $response->assertInertia(fn ($page) => $page->has('links', 1));
});

test('an administrator can update a guardian', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create(['notify_attendance' => true]);

    $response = $this->actingAs($admin)->put(route('guardians.update', $guardian), [
        'name' => 'Updated Name',
        'email' => $guardian->email,
        'mobile_number' => $guardian->mobile_number,
    ]);

    $response->assertRedirect(route('guardians.show', $guardian));
    $fresh = $guardian->fresh();
    expect($fresh->name)->toBe('Updated Name');
    expect($fresh->notify_attendance)->toBeFalse();

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'guardian.updated',
        'target_id' => $guardian->id,
    ]);
});

test('an administrator can activate and deactivate a guardian', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create(['status' => GuardianStatus::Active]);

    $this->actingAs($admin)->patch(route('guardians.deactivate', $guardian))->assertRedirect();
    expect($guardian->fresh()->status)->toBe(GuardianStatus::Inactive);
    $this->assertDatabaseHas('audit_logs', ['action' => 'guardian.deactivated', 'target_id' => $guardian->id]);

    $this->actingAs($admin)->patch(route('guardians.activate', $guardian))->assertRedirect();
    expect($guardian->fresh()->status)->toBe(GuardianStatus::Active);
    $this->assertDatabaseHas('audit_logs', ['action' => 'guardian.activated', 'target_id' => $guardian->id]);
});

test('an administrator can link a guardian to a student', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();

    $response = $this->actingAs($admin)->post(route('guardians.links.store', $guardian), [
        'student_id' => $student->id,
        'relationship_type' => 'mother',
        'is_primary_contact' => '1',
    ]);

    $response->assertRedirect();
    $link = GuardianStudentLink::query()->where('guardian_id', $guardian->id)->where('student_id', $student->id)->firstOrFail();
    expect($link->status)->toBe(GuardianStudentLinkStatus::Active);
    expect($link->is_primary_contact)->toBeTrue();

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'guardian_student_link.created',
        'target_id' => $link->id,
    ]);
});

test('linking an already-actively-linked student is rejected', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $response = $this->actingAs($admin)->post(route('guardians.links.store', $guardian), [
        'student_id' => $student->id,
        'relationship_type' => 'father',
    ]);

    $response->assertSessionHasErrors('student_id');
    expect(GuardianStudentLink::query()->count())->toBe(1);
});

test('re-linking after revocation reuses the same row instead of creating a new one', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create([
        'status' => GuardianStudentLinkStatus::Revoked,
        'relationship_type' => 'other',
    ]);

    $this->actingAs($admin)->post(route('guardians.links.store', $guardian), [
        'student_id' => $student->id,
        'relationship_type' => 'mother',
    ])->assertRedirect();

    expect(GuardianStudentLink::query()->count())->toBe(1);
    $fresh = $link->fresh();
    expect($fresh->id)->toBe($link->id);
    expect($fresh->status)->toBe(GuardianStudentLinkStatus::Active);
    expect($fresh->relationship_type->value)->toBe('mother');
});

test('an administrator can revoke a link', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($guardian)->for($student)->create(['status' => GuardianStudentLinkStatus::Active]);

    $response = $this->actingAs($admin)->patch(route('guardians.links.revoke', [$guardian, $link]));

    $response->assertRedirect();
    expect($link->fresh()->status)->toBe(GuardianStudentLinkStatus::Revoked);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'guardian_student_link.revoked',
        'target_id' => $link->id,
    ]);
});

test('revoking a link that does not belong to the given guardian returns 404', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $guardian = Guardian::factory()->create();
    $otherGuardian = Guardian::factory()->create();
    $student = Student::factory()->create();
    $link = GuardianStudentLink::factory()->for($otherGuardian)->for($student)->create();

    $this->actingAs($admin)->patch(route('guardians.links.revoke', [$guardian, $link]))->assertNotFound();
});
