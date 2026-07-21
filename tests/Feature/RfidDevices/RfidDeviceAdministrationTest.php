<?php

use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use App\Models\RfidDevice;
use App\Models\User;

test('a guardian is rejected from every rfid-devices route', function () {
    $guardian = User::factory()->create();
    $registration = (new RegisterRfidDevice)('GATE-001', 'Main Gate', RfidDeviceDirectionMode::Entry);
    $device = $registration->device;

    $this->actingAs($guardian)->get(route('rfid-devices.index'))->assertForbidden();
    $this->actingAs($guardian)->get(route('rfid-devices.create'))->assertForbidden();
    $this->actingAs($guardian)->post(route('rfid-devices.store'), [])->assertForbidden();
    $this->actingAs($guardian)->get(route('rfid-devices.show', $device))->assertForbidden();
    $this->actingAs($guardian)->get(route('rfid-devices.edit', $device))->assertForbidden();
    $this->actingAs($guardian)->put(route('rfid-devices.update', $device), [])->assertForbidden();
    $this->actingAs($guardian)->patch(route('rfid-devices.activate', $device))->assertForbidden();
    $this->actingAs($guardian)->patch(route('rfid-devices.revoke', $device))->assertForbidden();
});

test('an administrator can view, search, and filter the devices index', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    RfidDevice::factory()->create(['device_code' => 'GATE-001', 'status' => RfidDeviceStatus::Active]);
    RfidDevice::factory()->create(['device_code' => 'GATE-002', 'status' => RfidDeviceStatus::Revoked]);

    $this->actingAs($admin)->get(route('rfid-devices.index'))->assertOk();

    $response = $this->actingAs($admin)->get(route('rfid-devices.index', ['q' => 'GATE-001', 'status' => 'active']));

    $response->assertInertia(fn ($page) => $page->has('devices.data', 1));
});

test('an administrator can register a device and the plain secret is flashed exactly once', function () {
    $admin = User::factory()->schoolAdministrator()->create();

    $response = $this->actingAs($admin)->post(route('rfid-devices.store'), [
        'device_code' => 'GATE-001',
        'location' => 'Main Gate',
        'direction_mode' => 'entry',
    ]);

    $device = RfidDevice::query()->where('device_code', 'GATE-001')->firstOrFail();
    $response->assertRedirect(route('rfid-devices.show', $device));
    $response->assertInertiaFlash('rfidDeviceSecret');

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'rfid_device.registered',
        'target_type' => 'rfid_device',
        'target_id' => $device->id,
    ]);

    // A later visit to the show page must not carry the secret forward.
    $show = $this->actingAs($admin)->get(route('rfid-devices.show', $device));
    $show->assertOk();
    $show->assertInertiaFlashMissing('rfidDeviceSecret');
});

test('registering a device validates required fields and unique device_code', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $existing = RfidDevice::factory()->create(['device_code' => 'GATE-001']);

    $response = $this->actingAs($admin)->post(route('rfid-devices.store'), [
        'device_code' => $existing->device_code,
    ]);

    $response->assertSessionHasErrors(['device_code', 'location', 'direction_mode']);
    expect(RfidDevice::query()->count())->toBe(1);
});

test('an administrator can update a device\'s location and direction mode', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $device = RfidDevice::factory()->create(['location' => 'Old Location']);

    $response = $this->actingAs($admin)->put(route('rfid-devices.update', $device), [
        'location' => 'New Location',
        'direction_mode' => 'exit',
    ]);

    $response->assertRedirect(route('rfid-devices.show', $device));
    $fresh = $device->fresh();
    expect($fresh->location)->toBe('New Location');
    expect($fresh->direction_mode)->toBe(RfidDeviceDirectionMode::Exit);
});

test('an administrator can revoke and reactivate a device', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $device = RfidDevice::factory()->create(['status' => RfidDeviceStatus::Active]);

    $this->actingAs($admin)->patch(route('rfid-devices.revoke', $device))->assertRedirect();
    expect($device->fresh()->status)->toBe(RfidDeviceStatus::Revoked);
    $this->assertDatabaseHas('audit_logs', ['action' => 'rfid_device.revoked', 'target_id' => $device->id]);

    $this->actingAs($admin)->patch(route('rfid-devices.activate', $device))->assertRedirect();
    expect($device->fresh()->status)->toBe(RfidDeviceStatus::Active);
    $this->assertDatabaseHas('audit_logs', ['action' => 'rfid_device.activated', 'target_id' => $device->id]);
});
