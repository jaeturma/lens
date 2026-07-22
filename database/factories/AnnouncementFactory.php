<?php

namespace Database\Factories;

use App\Enums\AnnouncementAudienceType;
use App\Enums\AnnouncementStatus;
use App\Models\Announcement;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<Announcement>
 */
class AnnouncementFactory extends Factory
{
    protected $model = Announcement::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'title' => fake()->sentence(6),
            'body' => fake()->paragraphs(3, true),
            'author_id' => User::factory()->schoolAdministrator(),
            'status' => AnnouncementStatus::Draft,
            'published_at' => null,
            'expires_at' => null,
            'audience_type' => AnnouncementAudienceType::All,
            'audience_grade' => null,
            'audience_section' => null,
        ];
    }
}
