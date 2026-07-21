<?php

namespace Database\Factories;

use App\Models\School;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends Factory<School>
 */
class SchoolFactory extends Factory
{
    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'public_id' => Str::upper(fake()->unique()->bothify('SCH-####')),
            'name' => fake()->company().' School',
            'logo_url' => null,
        ];
    }
}
