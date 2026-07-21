<?php

namespace Database\Factories;

use App\Models\AttendanceRule;
use App\Models\School;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AttendanceRule>
 */
class AttendanceRuleFactory extends Factory
{
    protected $model = AttendanceRule::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'school_id' => School::factory(),
            'operating_days' => [1, 2, 3, 4, 5],
            'arrival_cutoff_time' => '07:30:00',
            'departure_time' => '16:00:00',
            'absence_cutoff_time' => '10:00:00',
            'duplicate_window_seconds' => 5,
        ];
    }
}
