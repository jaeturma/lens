<?php

use App\Enums\StudentSex;
use App\Enums\StudentStatus;
use App\Models\Student;
use Illuminate\Database\QueryException;
use Illuminate\Support\Str;

test('a uuid is generated on creation', function () {
    $student = Student::factory()->create();

    expect($student->uuid)->not->toBeEmpty();
});

test('the uuid is immutable once set', function () {
    $student = Student::factory()->create();

    $student->uuid = (string) Str::uuid();
    $student->save();
})->throws(LogicException::class);

test('sex and status are cast to their enums', function () {
    $student = Student::factory()->create([
        'sex' => StudentSex::Female,
        'status' => StudentStatus::Inactive,
    ]);

    $fresh = $student->fresh();

    expect($fresh->sex)->toBe(StudentSex::Female)
        ->and($fresh->status)->toBe(StudentStatus::Inactive);
});

test('lrn and student number must be unique', function () {
    $existing = Student::factory()->create();

    Student::factory()->create(['lrn' => $existing->lrn]);
})->throws(QueryException::class);
