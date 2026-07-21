<?php

namespace App\Models;

use App\Enums\GuardianStatus;
use App\Enums\GuardianStudentLinkStatus;
use App\Observers\GuardianObserver;
use Database\Factories\GuardianFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;
use LogicException;

/**
 * @property int $id
 * @property int $user_id
 * @property string $uuid
 * @property string $name
 * @property string $email
 * @property string $mobile_number
 * @property GuardianStatus $status
 * @property bool $notify_attendance
 * @property bool $notify_announcements
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read User $user
 */
#[Fillable(['user_id', 'name', 'email', 'mobile_number', 'status', 'notify_attendance', 'notify_announcements'])]
#[ObservedBy(GuardianObserver::class)]
class Guardian extends Model
{
    /** @use HasFactory<GuardianFactory> */
    use HasFactory;

    protected static function booted(): void
    {
        static::creating(function (Guardian $guardian): void {
            $guardian->uuid ??= (string) Str::uuid();
        });

        static::updating(function (Guardian $guardian): void {
            if ($guardian->isDirty('uuid')) {
                throw new LogicException('Guardian uuid is immutable and cannot be changed.');
            }
        });
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'status' => GuardianStatus::class,
            'notify_attendance' => 'boolean',
            'notify_announcements' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * @return HasMany<GuardianStudentLink, $this>
     */
    public function links(): HasMany
    {
        return $this->hasMany(GuardianStudentLink::class);
    }

    /**
     * @return HasMany<GuardianStudentLink, $this>
     */
    public function activeLinks(): HasMany
    {
        return $this->links()->where('status', GuardianStudentLinkStatus::Active);
    }
}
