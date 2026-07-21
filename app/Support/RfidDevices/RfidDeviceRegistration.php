<?php

namespace App\Support\RfidDevices;

use App\Models\RfidDevice;

final class RfidDeviceRegistration
{
    public function __construct(
        public readonly RfidDevice $device,
        public readonly string $plainSecret,
    ) {}
}
