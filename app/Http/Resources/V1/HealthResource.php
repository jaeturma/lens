<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @property string $status
 * @property string $app
 * @property string $version
 */
class HealthResource extends JsonResource
{
    /**
     * @return array<string, string>
     */
    public function toArray(Request $request): array
    {
        return [
            'status' => $this->status,
            'app' => $this->app,
            'version' => $this->version,
        ];
    }
}
