<?php

namespace Database\Factories;

use App\Enums\GuardianRelationshipType;
use App\Enums\GuardianStudentLinkStatus;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<GuardianStudentLink>
 */
class GuardianStudentLinkFactory extends Factory
{
    protected $model = GuardianStudentLink::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'student_id' => Student::factory(),
            'guardian_id' => Guardian::factory(),
            'relationship_type' => fake()->randomElement(GuardianRelationshipType::cases()),
            'is_primary_contact' => false,
            'status' => GuardianStudentLinkStatus::Active,
            'notifications_enabled' => true,
        ];
    }
}
