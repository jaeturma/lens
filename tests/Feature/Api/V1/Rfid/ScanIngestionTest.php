<?php

use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use App\Models\RfidScan;

function rfidBasicAuthHeader(string $deviceCode, string $secret): array
{
    return ['Authorization' => 'Basic '.base64_encode("{$deviceCode}:{$secret}")];
}

test('a valid device can submit a scan', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $response = $this->withHeaders(rfidBasicAuthHeader('GATE-001', $registration->plainSecret))
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'ABCD1234',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ]);

    $response->assertOk()->assertJson(['success' => true]);
    expect($response->json('data.id'))->toBeInt();

    $this->assertDatabaseHas('rfid_scans', [
        'rfid_device_id' => $registration->device->id,
        'uid' => 'ABCD1234',
        'request_id' => 'seq-1',
    ]);
});

test('a request with no credentials is rejected and nothing is stored', function () {
    $response = $this->postJson('/api/v1/rfid/scans', [
        'uid' => 'ABCD1234',
        'device_timestamp' => now()->toIso8601String(),
        'request_id' => 'seq-1',
    ]);

    $response->assertStatus(401)->assertJson(['success' => false]);
    expect(RfidScan::query()->count())->toBe(0);
});

test('an incorrect secret is rejected', function () {
    (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $response = $this->withHeaders(rfidBasicAuthHeader('GATE-001', 'wrong-secret'))
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'ABCD1234',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ]);

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('an unknown device_code is rejected', function () {
    $response = $this->withHeaders(rfidBasicAuthHeader('DOES-NOT-EXIST', 'anything'))
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'ABCD1234',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ]);

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a revoked device is rejected even with the correct secret', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $registration->device->update(['status' => RfidDeviceStatus::Revoked]);

    $response = $this->withHeaders(rfidBasicAuthHeader('GATE-001', $registration->plainSecret))
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'ABCD1234',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ]);

    $response->assertStatus(401)->assertJson(['success' => false]);
});

test('a malformed payload is rejected and nothing is stored', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $response = $this->withHeaders(rfidBasicAuthHeader('GATE-001', $registration->plainSecret))
        ->postJson('/api/v1/rfid/scans', []);

    $response->assertStatus(422)->assertJson(['success' => false]);
    expect(RfidScan::query()->count())->toBe(0);
});

test('replaying the same request_id returns the same scan id and stores only one row', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $headers = rfidBasicAuthHeader('GATE-001', $registration->plainSecret);
    $payload = [
        'uid' => 'ABCD1234',
        'device_timestamp' => now()->toIso8601String(),
        'request_id' => 'seq-1',
    ];

    $first = $this->withHeaders($headers)->postJson('/api/v1/rfid/scans', $payload);
    $replay = $this->withHeaders($headers)->postJson('/api/v1/rfid/scans', $payload);

    $first->assertOk();
    $replay->assertOk();
    expect($replay->json('data.id'))->toBe($first->json('data.id'));
    expect(RfidScan::query()->count())->toBe(1);
});

test('a scan for a uid with no assigned card is stored and classified unknown_card', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);

    $this->withHeaders(rfidBasicAuthHeader('GATE-001', $registration->plainSecret))
        ->postJson('/api/v1/rfid/scans', [
            'uid' => 'NEVER-SEEN',
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => 'seq-1',
        ])->assertOk();

    $this->assertDatabaseHas('rfid_scans', [
        'uid' => 'NEVER-SEEN',
        'classification' => 'unknown_card',
    ]);
});

test('the scan endpoint is rate limited per device', function () {
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $headers = rfidBasicAuthHeader('GATE-001', $registration->plainSecret);

    for ($i = 0; $i < 120; $i++) {
        $this->withHeaders($headers)->postJson('/api/v1/rfid/scans', [
            'uid' => "UID{$i}",
            'device_timestamp' => now()->toIso8601String(),
            'request_id' => "seq-{$i}",
        ])->assertOk();
    }

    $this->withHeaders($headers)->postJson('/api/v1/rfid/scans', [
        'uid' => 'UID-OVER-LIMIT',
        'device_timestamp' => now()->toIso8601String(),
        'request_id' => 'seq-over',
    ])->assertStatus(429);
});
