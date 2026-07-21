<?php

namespace Database\Factories;

use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidDeviceStatus;
use App\Models\RfidDevice;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends Factory<RfidDevice>
 */
class RfidDeviceFactory extends Factory
{
    protected $model = RfidDevice::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'device_code' => fake()->unique()->bothify('GATE-####'),
            'location' => fake()->randomElement(['Main Gate', 'Back Gate', 'Library Entrance']),
            'direction_mode' => fake()->randomElement(RfidDeviceDirectionMode::cases()),
            'secret' => Hash::make(Str::random(40)),
            'status' => RfidDeviceStatus::Active,
            'last_activity_at' => null,
        ];
    }
}
