<?php

namespace Database\Factories;

use App\Enums\StudentSex;
use App\Enums\StudentStatus;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Student>
 */
class StudentFactory extends Factory
{
    protected $model = Student::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'lrn' => fake()->unique()->numerify('############'),
            'student_number' => fake()->unique()->bothify('SN-####'),
            'name' => fake()->name(),
            'sex' => fake()->randomElement(StudentSex::cases()),
            'grade' => fake()->randomElement(['Grade 7', 'Grade 8', 'Grade 9', 'Grade 10']),
            'section' => fake()->randomElement(['Diamond', 'Emerald', 'Sapphire']),
            'school_year' => '2026-2027',
            'status' => StudentStatus::Active,
            'photo_url' => null,
        ];
    }
}
