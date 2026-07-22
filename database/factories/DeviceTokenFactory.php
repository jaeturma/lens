<?php

namespace Database\Factories;

use App\Enums\DeviceTokenStatus;
use App\Models\DeviceToken;
use App\Models\Guardian;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<DeviceToken>
 */
class DeviceTokenFactory extends Factory
{
    protected $model = DeviceToken::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'guardian_id' => Guardian::factory(),
            'token' => fake()->unique()->regexify('[A-Za-z0-9_-]{140,163}'),
            'status' => DeviceTokenStatus::Active,
            'revoked_at' => null,
        ];
    }
}
