<?php

use App\Enums\GuardianStatus;
use App\Models\Guardian;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Str;

test('a uuid is generated on creation', function () {
    $guardian = Guardian::factory()->create();

    expect($guardian->uuid)->not->toBeEmpty();
});

test('the uuid is immutable once set', function () {
    $guardian = Guardian::factory()->create();

    $guardian->uuid = (string) Str::uuid();
    $guardian->save();
})->throws(LogicException::class);

test('status is cast to its enum', function () {
    $guardian = Guardian::factory()->create(['status' => GuardianStatus::Inactive]);

    expect($guardian->fresh()->status)->toBe(GuardianStatus::Inactive);
});

test('a user may only have one guardian profile', function () {
    $user = User::factory()->create();
    Guardian::factory()->for($user)->create();

    Guardian::factory()->for($user)->create();
})->throws(QueryException::class);

test('a user has a guardian relationship', function () {
    $user = User::factory()->create();
    $guardian = Guardian::factory()->for($user)->create();

    expect($user->fresh()->guardian->is($guardian))->toBeTrue();
});
