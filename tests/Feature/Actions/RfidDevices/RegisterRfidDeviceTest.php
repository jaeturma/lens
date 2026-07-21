<?php

use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use App\Models\RfidDevice;
use Illuminate\Support\Facades\Hash;

test('it creates an active device and returns the plain secret exactly once', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    expect($registration->device)->toBeInstanceOf(RfidDevice::class)
        ->and($registration->device->device_code)->toBe('GATE-001')
        ->and($registration->device->location)->toBe('Main Gate')
        ->and($registration->device->direction_mode)->toBe(RfidDeviceDirectionMode::Entry)
        ->and($registration->device->status)->toBe(RfidDeviceStatus::Active)
        ->and($registration->plainSecret)->toBeString()->not->toBeEmpty();

    expect(Hash::check($registration->plainSecret, $registration->device->secret))->toBeTrue();
});

test('each registration generates a different secret', function () {
    $first = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $second = (new RegisterRfidDevice)('GATE-002', 'Back Gate', RfidDeviceDirectionMode::Exit);

    expect($first->plainSecret)->not->toBe($second->plainSecret);
});
