<?php

namespace Database\Factories;

use App\Enums\NotificationDeliveryStatus;
use App\Enums\NotificationType;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<GuardianNotification>
 */
class GuardianNotificationFactory extends Factory
{
    protected $model = GuardianNotification::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'guardian_id' => Guardian::factory(),
            'type' => NotificationType::Arrival,
            'title' => fake()->sentence(4),
            'body' => fake()->sentence(12),
            'payload' => null,
            'read_at' => null,
            'delivery_status' => NotificationDeliveryStatus::Pending,
        ];
    }
}
