<?php

namespace App\Http\Resources\V1;

use App\Models\SyncChange;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Collection;

/**
 * @property string $next_cursor
 * @property bool $has_more
 * @property Collection<int, SyncChange> $changes
 */
class SyncChangesResource extends JsonResource
{
    /**
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'next_cursor' => $this->next_cursor,
            'has_more' => $this->has_more,
            'changes' => SyncChangeResource::collection($this->changes),
        ];
    }
}
