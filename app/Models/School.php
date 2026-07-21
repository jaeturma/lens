<?php

namespace App\Models;

use Database\Factories\SchoolFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use LogicException;

/**
 * @property int $id
 * @property string $uuid
 * @property string $public_id
 * @property string $name
 * @property string|null $logo_url
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read SchoolSettings|null $settings
 */
#[Fillable(['public_id', 'name', 'logo_url'])]
class School extends Model
{
    /** @use HasFactory<SchoolFactory> */
    use HasFactory;

    protected static function booted(): void
    {
        static::creating(function (School $school): void {
            $school->uuid ??= (string) Str::uuid();
        });

        static::updating(function (School $school): void {
            if ($school->isDirty('uuid')) {
                throw new LogicException('School uuid is immutable and cannot be changed.');
            }
        });
    }

    /**
     * @return HasOne<SchoolSettings, $this>
     */
    public function settings(): HasOne
    {
        return $this->hasOne(SchoolSettings::class);
    }
}
