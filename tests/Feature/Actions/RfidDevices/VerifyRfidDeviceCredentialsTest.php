<?php

use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Actions\RfidDevices\VerifyRfidDeviceCredentials;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;

test('correct credentials for an active device succeed and update last_activity_at', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $verified = (new VerifyRfidDeviceCredentials)('GATE-001', $registration->plainSecret);

    expect($verified)->not->toBeNull();
    expect($verified->id)->toBe($registration->device->id);
    expect($verified->fresh()->last_activity_at)->not->toBeNull();
});

test('an incorrect secret fails verification', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $verified = (new VerifyRfidDeviceCredentials)('GATE-001', 'wrong-secret');

    expect($verified)->toBeNull();
});

test('an unknown device_code fails verification', function () {
    $verified = (new VerifyRfidDeviceCredentials)('DOES-NOT-EXIST', 'anything');

    expect($verified)->toBeNull();
});

test('a revoked device fails verification even with the correct secret', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $registration->device->update(['status' => RfidDeviceStatus::Revoked]);

    $verified = (new VerifyRfidDeviceCredentials)('GATE-001', $registration->plainSecret);

    expect($verified)->toBeNull();
});
