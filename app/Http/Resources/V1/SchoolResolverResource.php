<?php

namespace App\Http\Resources\V1;

use App\Models\School;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin School
 */
class SchoolResolverResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'school_id' => $this->public_id,
            'uuid' => $this->uuid,
            'name' => $this->name,
            'logo_url' => $this->logo_url,
            'timezone' => $this->settings->timezone,
            'mobile_enabled' => $this->settings->mobile_enabled,
            'maintenance_mode' => $this->settings->maintenance_mode,
            'maintenance_message' => $this->settings->maintenance_message,
            'notifications_enabled' => $this->settings->notifications_enabled,
            'minimum_app_version' => $this->settings->minimum_app_version,
        ];
    }
}
