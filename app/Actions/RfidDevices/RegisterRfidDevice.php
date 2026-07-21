<?php

namespace App\Actions\RfidDevices;

use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use App\Models\RfidDevice;
use App\Support\RfidDevices\RfidDeviceRegistration;
use Illuminate\Support\Str;

class RegisterRfidDevice
{
    public function __invoke(string $deviceCode, string $location, RfidDeviceDirectionMode $directionMode): RfidDeviceRegistration
    {
        $plainSecret = Str::random(40);

        $device = RfidDevice::create([
            'device_code' => $deviceCode,
            'location' => $location,
            'direction_mode' => $directionMode,
            'secret' => $plainSecret,
            'status' => RfidDeviceStatus::Active,
        ]);

        return new RfidDeviceRegistration($device, $plainSecret);
    }
}
