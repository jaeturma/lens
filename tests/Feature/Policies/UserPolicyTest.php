<?php

use App\Models\User;
use App\Policies\UserPolicy;

test('a user may view and update their own account', function () {
    $user = User::factory()->create();
    $policy = new UserPolicy;

    expect($policy->view($user, $user))->toBeTrue();
    expect($policy->update($user, $user))->toBeTrue();
});

test('a user may not view or update another account', function () {
    $user = User::factory()->create();
    $other = User::factory()->create();
    $policy = new UserPolicy;

    expect($policy->view($user, $other))->toBeFalse();
    expect($policy->update($user, $other))->toBeFalse();
});
