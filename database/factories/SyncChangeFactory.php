<?php

namespace Database\Factories;

use App\Enums\SyncChangeAction;
use App\Models\SyncChange;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<SyncChange>
 */
class SyncChangeFactory extends Factory
{
    protected $model = SyncChange::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'resource_type' => 'test_resource',
            'resource_id' => fake()->randomNumber(),
            'action' => SyncChangeAction::Created,
            'payload' => [],
        ];
    }
}
