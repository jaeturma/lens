<?php

use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use App\Models\RfidDevice;
use Illuminate\Database\QueryException;

test('device_code must be unique', function () {
    $existing = RfidDevice::factory()->create();

    RfidDevice::factory()->create(['device_code' => $existing->device_code]);
})->throws(QueryException::class);

test('the secret is never present in the serialized model', function () {
    $device = RfidDevice::factory()->create();

    expect($device->toArray())->not->toHaveKey('secret');
    expect($device->toJson())->not->toContain('secret');
});

test('direction_mode and status are cast to their enums', function () {
    $device = RfidDevice::factory()->create([
        'direction_mode' => RfidDeviceDirectionMode::Exit,
        'status' => RfidDeviceStatus::Revoked,
    ]);

    $fresh = $device->fresh();

    expect($fresh->direction_mode)->toBe(RfidDeviceDirectionMode::Exit)
        ->and($fresh->status)->toBe(RfidDeviceStatus::Revoked);
});
