<?php

namespace App\Models;

use Database\Factories\SchoolSettingsFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $school_id
 * @property string $timezone
 * @property bool $mobile_enabled
 * @property bool $maintenance_mode
 * @property string|null $maintenance_message
 * @property bool $notifications_enabled
 * @property string $minimum_app_version
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read School $school
 */
#[Fillable(['timezone', 'mobile_enabled', 'maintenance_mode', 'maintenance_message', 'notifications_enabled', 'minimum_app_version'])]
class SchoolSettings extends Model
{
    /** @use HasFactory<SchoolSettingsFactory> */
    use HasFactory;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'mobile_enabled' => 'boolean',
            'maintenance_mode' => 'boolean',
            'notifications_enabled' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<School, $this>
     */
    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }
}
