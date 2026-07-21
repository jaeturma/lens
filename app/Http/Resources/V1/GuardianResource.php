<?php

namespace App\Http\Resources\V1;

use App\Models\Guardian;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Guardian
 */
class GuardianResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'uuid' => $this->uuid,
            'name' => $this->name,
            'email' => $this->email,
            'mobile_number' => $this->mobile_number,
            'status' => $this->status->value,
            'notify_attendance' => $this->notify_attendance,
            'notify_announcements' => $this->notify_announcements,
        ];
    }
}
