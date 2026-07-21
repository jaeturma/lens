<?php

namespace App\Http\Resources\V1;

use App\Models\SyncChange;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin SyncChange
 */
class SyncChangeResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'resource_type' => $this->resource_type,
            'resource_id' => $this->resource_id,
            'action' => $this->action->value,
            'payload' => $this->payload,
            'created_at' => $this->created_at->format('Y-m-d\TH:i:s\Z'),
        ];
    }
}
