<?php

use App\Enums\RfidScanClassification;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\User;

test('a guardian is rejected from the rfid-scans route', function () {
    $guardian = User::factory()->create();

    $this->actingAs($guardian)->get(route('rfid-scans.index'))->assertForbidden();
});

test('an administrator can view and filter recent scans', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $deviceA = RfidDevice::factory()->create();
    $deviceB = RfidDevice::factory()->create();
    RfidScan::factory()->for($deviceA, 'device')->create(['classification' => RfidScanClassification::Valid]);
    RfidScan::factory()->for($deviceB, 'device')->create(['classification' => RfidScanClassification::UnknownCard]);

    $this->actingAs($admin)->get(route('rfid-scans.index'))->assertOk();

    $response = $this->actingAs($admin)->get(route('rfid-scans.index', [
        'rfid_device_id' => $deviceA->id,
        'classification' => 'valid',
    ]));

    $response->assertInertia(fn ($page) => $page->has('scans.data', 1));
});
