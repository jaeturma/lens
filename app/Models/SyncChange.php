<?php

namespace App\Models;

use App\Enums\SyncChangeAction;
use Database\Factories\SyncChangeFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property string $resource_type
 * @property int $resource_id
 * @property SyncChangeAction $action
 * @property array<string, mixed>|null $payload
 * @property Carbon $created_at
 * @property-read Model $resource
 */
#[Fillable(['resource_type', 'resource_id', 'action', 'payload'])]
class SyncChange extends Model
{
    /** @use HasFactory<SyncChangeFactory> */
    use HasFactory;

    const UPDATED_AT = null;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'action' => SyncChangeAction::class,
            'payload' => 'array',
            'created_at' => 'datetime',
        ];
    }

    /**
     * @return MorphTo<Model, $this>
     */
    public function resource(): MorphTo
    {
        return $this->morphTo();
    }
}
