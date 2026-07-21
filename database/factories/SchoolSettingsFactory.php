<?php

namespace Database\Factories;

use App\Models\School;
use App\Models\SchoolSettings;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<SchoolSettings>
 */
class SchoolSettingsFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'school_id' => School::factory(),
            'timezone' => 'Asia/Manila',
            'mobile_enabled' => true,
            'maintenance_mode' => false,
            'maintenance_message' => null,
            'notifications_enabled' => true,
            'minimum_app_version' => '0.1.0',
        ];
    }
}
