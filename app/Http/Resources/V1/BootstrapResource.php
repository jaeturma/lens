<?php

namespace App\Http\Resources\V1;

use App\Models\School;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property School $school
 * @property User $user
 * @property string $next_cursor
 */
class BootstrapResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'school' => new SchoolResolverResource($this->school),
            'user' => new UserResource($this->user),
            'next_cursor' => $this->next_cursor,
        ];
    }
}
