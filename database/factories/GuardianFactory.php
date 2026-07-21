<?php

namespace Database\Factories;

use App\Enums\GuardianStatus;
use App\Models\Guardian;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Guardian>
 */
class GuardianFactory extends Factory
{
    protected $model = Guardian::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'name' => fake()->name(),
            'email' => fake()->unique()->safeEmail(),
            'mobile_number' => fake()->numerify('09#########'),
            'status' => GuardianStatus::Active,
            'notify_attendance' => true,
            'notify_announcements' => true,
        ];
    }
}
