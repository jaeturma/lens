<?php

namespace App\Http\Resources\V1;

use App\Models\Announcement;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use App\Models\School;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Collection;

/**
 * @property School $school
 * @property User $user
 * @property Guardian|null $guardian
 * @property Collection<int, GuardianStudentLink> $children
 * @property Collection<int, Announcement> $announcements
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
            'guardian' => $this->guardian ? new GuardianResource($this->guardian) : null,
            'children' => LinkedStudentResource::collection($this->children),
            'announcements' => AnnouncementResource::collection($this->announcements),
            'next_cursor' => $this->next_cursor,
        ];
    }
}
