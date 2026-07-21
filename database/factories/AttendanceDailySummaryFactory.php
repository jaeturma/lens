<?php

namespace Database\Factories;

use App\Models\AttendanceDailySummary;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AttendanceDailySummary>
 */
class AttendanceDailySummaryFactory extends Factory
{
    protected $model = AttendanceDailySummary::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'student_id' => Student::factory(),
            'date' => now()->toDateString(),
            'arrival_event_id' => null,
            'departure_event_id' => null,
        ];
    }
}
