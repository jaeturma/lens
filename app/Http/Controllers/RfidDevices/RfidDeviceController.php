<?php

namespace App\Http\Controllers\RfidDevices;

use App\Actions\Audit\RecordAuditLog;
use App\Actions\RfidDevices\RegisterRfidDevice;
use App\Enums\RfidDeviceDirectionMode;
use App\Http\Controllers\Controller;
use App\Http\Requests\RfidDevices\IndexRfidDevicesRequest;
use App\Http\Requests\RfidDevices\StoreRfidDeviceRequest;
use App\Http\Requests\RfidDevices\UpdateRfidDeviceRequest;
use App\Models\RfidDevice;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class RfidDeviceController extends Controller
{
    public function index(IndexRfidDevicesRequest $request): Response
    {
        $filters = $request->filters();

        $devices = RfidDevice::query()
            ->when($filters['q'] ?? null, function ($query, string $q) {
                $query->where(function ($query) use ($q) {
                    $query->where('device_code', 'like', "%{$q}%")
                        ->orWhere('location', 'like', "%{$q}%");
                });
            })
            ->when($filters['status'] ?? null, fn ($query, string $status) => $query->where('status', $status))
            ->orderBy('device_code')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('rfid/devices/index', [
            'devices' => $devices,
            'filters' => $filters,
        ]);
    }

    public function create(): Response
    {
        $this->authorize('create', RfidDevice::class);

        return Inertia::render('rfid/devices/create');
    }

    public function store(StoreRfidDeviceRequest $request, RegisterRfidDevice $registerRfidDevice, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $validated = $request->validated();

        $registration = $registerRfidDevice(
            $validated['device_code'],
            $validated['location'],
            RfidDeviceDirectionMode::from($validated['direction_mode']),
        );

        $recordAuditLog($request->user(), 'rfid_device.registered', $registration->device, [
            'device_code' => $registration->device->device_code,
        ]);

        Inertia::flash('rfidDeviceSecret', $registration->plainSecret);
        Inertia::flash('toast', ['type' => 'success', 'message' => 'Device registered.']);

        return to_route('rfid-devices.show', $registration->device);
    }

    public function show(RfidDevice $rfidDevice): Response
    {
        $this->authorize('view', $rfidDevice);

        return Inertia::render('rfid/devices/show', [
            'device' => $rfidDevice,
        ]);
    }

    public function edit(RfidDevice $rfidDevice): Response
    {
        $this->authorize('update', $rfidDevice);

        return Inertia::render('rfid/devices/edit', [
            'device' => $rfidDevice,
        ]);
    }

    public function update(UpdateRfidDeviceRequest $request, RfidDevice $rfidDevice, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $rfidDevice->update($request->validated());

        $recordAuditLog($request->user(), 'rfid_device.updated', $rfidDevice, [
            'device_code' => $rfidDevice->device_code,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Device updated.']);

        return to_route('rfid-devices.show', $rfidDevice);
    }
}
