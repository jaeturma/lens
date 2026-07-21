<?php

use App\Models\School;
use App\Models\SchoolSettings;
use Illuminate\Database\QueryException;
use Illuminate\Support\Str;

test('a uuid is generated automatically on creation', function () {
    $school = School::factory()->create();

    expect($school->uuid)->not->toBeEmpty();
});

test('the uuid cannot be changed after creation', function () {
    $school = School::factory()->create();

    $school->uuid = (string) Str::uuid();

    $school->save();
})->throws(LogicException::class, 'School uuid is immutable and cannot be changed.');

test('public_id must be unique', function () {
    School::factory()->create(['public_id' => 'SCH-0001']);

    School::factory()->create(['public_id' => 'SCH-0001']);
})->throws(QueryException::class);

test('uuid must be unique', function () {
    $existing = School::factory()->create();

    School::factory()->create()->forceFill(['uuid' => $existing->uuid])->saveQuietly();
})->throws(QueryException::class);

test('a school has one settings record', function () {
    $school = School::factory()->create();
    $settings = SchoolSettings::factory()->for($school)->create();

    expect($school->refresh()->settings->is($settings))->toBeTrue()
        ->and($settings->school->is($school))->toBeTrue();
});

test('school_id is unique per school settings record', function () {
    $school = School::factory()->create();
    SchoolSettings::factory()->for($school)->create();

    SchoolSettings::factory()->for($school)->create();
})->throws(QueryException::class);
