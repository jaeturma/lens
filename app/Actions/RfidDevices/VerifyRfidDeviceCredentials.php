<?php

namespace App\Actions\RfidDevices;

use App\Enums\RfidDeviceStatus;
use App\Models\RfidDevice;
use Illuminate\Support\Facades\Hash;

class VerifyRfidDeviceCredentials
{
    public function __invoke(string $deviceCode, string $secret): ?RfidDevice
    {
        $device = RfidDevice::query()->where('device_code', $deviceCode)->first();

        if (! $device || $device->status !== RfidDeviceStatus::Active) {
            return null;
        }

        if (! Hash::check($secret, $device->secret)) {
            return null;
        }

        $device->forceFill(['last_activity_at' => now()])->save();

        return $device;
    }
}
