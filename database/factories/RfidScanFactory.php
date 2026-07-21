<?php

namespace Database\Factories;

use App\Models\RfidDevice;
use App\Models\RfidScan;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RfidScan>
 */
class RfidScanFactory extends Factory
{
    protected $model = RfidScan::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'rfid_device_id' => RfidDevice::factory(),
            'uid' => fake()->unique()->regexify('[A-F0-9]{8}'),
            'device_timestamp' => now(),
            'request_id' => (string) fake()->unique()->numberBetween(1, 1_000_000),
        ];
    }
}
