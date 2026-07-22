<?php

use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Enums\RfidDeviceDirectionMode;
use App\Models\RfidScan;
use App\Models\User;

/**
 * WP-08-06: "device/user auth separation is proven." Structurally these
 * two credential spaces are already disjoint — `App\Http\Middleware\AuthenticateRfidDevice`
 * checks Basic Auth against `rfid_devices` (`App\Actions\RfidDevices\VerifyRfidDeviceCredentials`),
 * completely independent of Sanctum's bearer-token lookup against
 * `personal_access_tokens` — but nothing asserted that separation directly
 * until now.
 */
test('a guardian\'s Sanctum bearer token is rejected when presented as RFID device Basic Auth credentials', function () {
    bindSchool();
    $user = User::factory()->create();
    $token = $user->createToken('mobile')->plainTextToken;

    $response = $this->withHeaders([
        'Authorization' => 'Basic '.base64_encode($token.':anything'),
    ])->postJson('/api/v1/rfid/scans', [
        'uid' => 'ABCD1234',
        'device_timestamp' => now()->toIso8601String(),
        'request_id' => 'seq-1',
    ]);

    $response->assertStatus(401)->assertJson(['success' => false]);
    expect(RfidScan::query()->count())->toBe(0);
});

test('an RFID device\'s Basic Auth credentials are rejected when presented as a Sanctum bearer token', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $response = $this->withToken($registration->plainSecret)->getJson('/api/v1/auth/me');

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('an RFID device\'s device_code is rejected when presented as a Sanctum bearer token', function () {
    (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $response = $this->withToken('GATE-001')->getJson('/api/v1/auth/me');

    $response->assertStatus(401)->assertJson(['success' => false]);
});
