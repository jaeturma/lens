<?php

namespace Database\Factories;

use App\Enums\RfidCardStatus;
use App\Models\RfidCard;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<RfidCard>
 */
class RfidCardFactory extends Factory
{
    protected $model = RfidCard::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'uid' => fake()->unique()->regexify('[A-F0-9]{8}'),
            'student_id' => Student::factory(),
            'status' => RfidCardStatus::Active,
        ];
    }
}
