<?php

namespace App\Http\Controllers\RfidDevices;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\RfidDeviceStatus;
use App\Http\Controllers\Controller;
use App\Models\RfidDevice;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;

class RevokeRfidDeviceController extends Controller
{
    public function __invoke(Request $request, RfidDevice $rfidDevice, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $this->authorize('update', $rfidDevice);

        $rfidDevice->update(['status' => RfidDeviceStatus::Revoked]);

        $recordAuditLog($request->user(), 'rfid_device.revoked', $rfidDevice, [
            'device_code' => $rfidDevice->device_code,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Device revoked.']);

        return back();
    }
}
