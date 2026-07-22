<?php

namespace Database\Factories;

use App\Models\GuardianNotification;
use App\Models\PushDeliveryAttempt;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<PushDeliveryAttempt>
 */
class PushDeliveryAttemptFactory extends Factory
{
    protected $model = PushDeliveryAttempt::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'guardian_notification_id' => GuardianNotification::factory(),
            'attempt_number' => 1,
            'succeeded' => true,
            'error_message' => null,
        ];
    }
}
