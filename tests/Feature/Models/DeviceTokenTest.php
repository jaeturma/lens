<?php

use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;
use Illuminate\Database\QueryException;

test('token must be unique', function () {
    $existing = DeviceToken::factory()->create();

    DeviceToken::factory()->create(['token' => $existing->token]);
})->throws(QueryException::class);

test('the raw token is never present in the serialized model', function () {
    $deviceToken = DeviceToken::factory()->create();

    expect($deviceToken->toArray())->not->toHaveKey('token');
    expect($deviceToken->toJson())->not->toContain($deviceToken->token);
});

test('status defaults to active', function () {
    $deviceToken = DeviceToken::factory()->create();

    expect($deviceToken->status)->toBe(DeviceTokenStatus::Active);
    expect($deviceToken->revoked_at)->toBeNull();
});
