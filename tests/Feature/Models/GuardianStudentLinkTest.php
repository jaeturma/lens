<?php

use App\Enums\GuardianStudentLinkStatus;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\Student;
use Illuminate\Database\QueryException;
use Illuminate\Support\Str;

test('a uuid is generated on creation', function () {
    $link = GuardianStudentLink::factory()->create();

    expect($link->uuid)->not->toBeEmpty();
});

test('the uuid is immutable once set', function () {
    $link = GuardianStudentLink::factory()->create();

    $link->uuid = (string) Str::uuid();
    $link->save();
})->throws(LogicException::class);

test('a student and guardian pair cannot have more than one link row', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create();
    GuardianStudentLink::factory()->for($student)->for($guardian)->create();

    GuardianStudentLink::factory()->for($student)->for($guardian)->create();
})->throws(QueryException::class);

test('activeLinks excludes revoked links', function () {
    $student = Student::factory()->create();
    $guardian = Guardian::factory()->create();

    $active = GuardianStudentLink::factory()->for($student)->for($guardian)->create();
    $revokedStudent = Student::factory()->create();
    GuardianStudentLink::factory()
        ->for($revokedStudent)
        ->for($guardian)
        ->create(['status' => GuardianStudentLinkStatus::Revoked]);

    $links = $guardian->activeLinks()->get();

    expect($links)->toHaveCount(1);
    expect($links->first()->is($active))->toBeTrue();
});
