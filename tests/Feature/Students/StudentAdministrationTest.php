<?php

use App\Enums\StudentStatus;
use App\Models\AuditLog;
use App\Models\Student;
use App\Models\User;

test('a guardian is rejected from every students route', function () {
    $guardian = User::factory()->create();
    $student = Student::factory()->create();

    $this->actingAs($guardian)->get(route('students.index'))->assertForbidden();
    $this->actingAs($guardian)->get(route('students.create'))->assertForbidden();
    $this->actingAs($guardian)->post(route('students.store'), [])->assertForbidden();
    $this->actingAs($guardian)->get(route('students.show', $student))->assertForbidden();
    $this->actingAs($guardian)->get(route('students.edit', $student))->assertForbidden();
    $this->actingAs($guardian)->put(route('students.update', $student), [])->assertForbidden();
    $this->actingAs($guardian)->patch(route('students.activate', $student))->assertForbidden();
    $this->actingAs($guardian)->patch(route('students.deactivate', $student))->assertForbidden();
});

test('a school administrator can view the students index', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    Student::factory()->count(3)->create();

    $this->actingAs($admin)->get(route('students.index'))->assertOk();
});

test('a system administrator can view the students index', function () {
    $admin = User::factory()->systemAdministrator()->create();

    $this->actingAs($admin)->get(route('students.index'))->assertOk();
});

test('the index searches by name, lrn, and student number', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $match = Student::factory()->create(['name' => 'Juan Dela Cruz']);
    Student::factory()->create(['name' => 'Someone Else']);

    $response = $this->actingAs($admin)->get(route('students.index', ['q' => 'Dela Cruz']));

    $response->assertOk();
    $response->assertInertia(fn ($page) => $page
        ->has('students.data', 1)
        ->where('students.data.0.id', $match->id)
    );
});

test('the index filters by grade, section, school_year, and status', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $match = Student::factory()->create([
        'grade' => 'Grade 10',
        'section' => 'Diamond',
        'school_year' => '2026-2027',
        'status' => StudentStatus::Active,
    ]);
    Student::factory()->create(['grade' => 'Grade 9']);

    $response = $this->actingAs($admin)->get(route('students.index', [
        'grade' => 'Grade 10',
        'section' => 'Diamond',
        'school_year' => '2026-2027',
        'status' => 'active',
    ]));

    $response->assertInertia(fn ($page) => $page
        ->has('students.data', 1)
        ->where('students.data.0.id', $match->id)
    );
});

test('an administrator can create a student', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('students.store'), [
        'lrn' => '123456789012',
        'student_number' => 'SN-0001',
        'name' => 'Juan Dela Cruz',
        'sex' => 'male',
        'grade' => 'Grade 7',
        'section' => 'Diamond',
        'school_year' => '2026-2027',
    ]);

    $student = Student::query()->where('lrn', '123456789012')->firstOrFail();
    $response->assertRedirect(route('students.show', $student));

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'student.created',
        'target_type' => 'student',
        'target_id' => $student->id,
    ]);
});

test('creating a student validates required and unique fields', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $existing = Student::factory()->create();

    $response = $this->actingAs($admin)->post(route('students.store'), [
        'lrn' => $existing->lrn,
        'student_number' => $existing->student_number,
    ]);

    $response->assertSessionHasErrors(['lrn', 'student_number', 'name', 'sex', 'grade', 'section', 'school_year']);
    expect(Student::query()->count())->toBe(1);
});

test('an administrator can view a student', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();

    $this->actingAs($admin)->get(route('students.show', $student))->assertOk();
});

test('an administrator can update a student', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();

    $response = $this->actingAs($admin)->put(route('students.update', $student), [
        'lrn' => $student->lrn,
        'student_number' => $student->student_number,
        'name' => 'Updated Name',
        'sex' => $student->sex->value,
        'grade' => $student->grade,
        'section' => $student->section,
        'school_year' => $student->school_year,
    ]);

    $response->assertRedirect(route('students.show', $student));
    expect($student->fresh()->name)->toBe('Updated Name');

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'student.updated',
        'target_type' => 'student',
        'target_id' => $student->id,
    ]);
});

test('updating a student excludes itself from the unique lrn/student_number check', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();

    $response = $this->actingAs($admin)->put(route('students.update', $student), [
        'lrn' => $student->lrn,
        'student_number' => $student->student_number,
        'name' => 'Same Record Updated',
        'sex' => $student->sex->value,
        'grade' => $student->grade,
        'section' => $student->section,
        'school_year' => $student->school_year,
    ]);

    $response->assertSessionHasNoErrors();
});

test('an administrator can activate and deactivate a student', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create(['status' => StudentStatus::Active]);

    $this->actingAs($admin)->patch(route('students.deactivate', $student))->assertRedirect();
    expect($student->fresh()->status)->toBe(StudentStatus::Inactive);
    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'student.deactivated',
        'target_id' => $student->id,
    ]);

    $this->actingAs($admin)->patch(route('students.activate', $student))->assertRedirect();
    expect($student->fresh()->status)->toBe(StudentStatus::Active);
    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'student.activated',
        'target_id' => $student->id,
    ]);
});

test('audit log metadata does not include unrelated columns', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();

    $this->actingAs($admin)->patch(route('students.deactivate', $student));

    $log = AuditLog::query()->latest('id')->first();
    expect($log->metadata)->toBe([]);
});
