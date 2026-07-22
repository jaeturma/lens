<?php

namespace App\Models;

use App\Enums\NotificationDeliveryStatus;
use App\Enums\NotificationType;
use App\Observers\GuardianNotificationObserver;
use Database\Factories\GuardianNotificationFactory;
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
 * @property string $uuid
 * @property int $guardian_id
 * @property NotificationType $type
 * @property string $title
 * @property string $body
 * @property array<string, mixed>|null $payload
 * @property Carbon|null $read_at
 * @property NotificationDeliveryStatus $delivery_status
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read Guardian $guardian
 */
#[Fillable(['guardian_id', 'type', 'title', 'body', 'payload', 'read_at', 'delivery_status'])]
#[ObservedBy(GuardianNotificationObserver::class)]
class GuardianNotification extends Model
{
    /** @use HasFactory<GuardianNotificationFactory> */
    use HasFactory;

    protected static function booted(): void
    {
        static::creating(function (GuardianNotification $notification): void {
            $notification->uuid ??= (string) Str::uuid();
            $notification->delivery_status ??= NotificationDeliveryStatus::Pending;
        });

        static::updating(function (GuardianNotification $notification): void {
            if ($notification->isDirty('uuid')) {
                throw new LogicException('GuardianNotification uuid is immutable and cannot be changed.');
            }
        });
    }

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'type' => NotificationType::class,
            'payload' => 'array',
            'read_at' => 'datetime',
            'delivery_status' => NotificationDeliveryStatus::class,
        ];
    }

    /**
     * @return BelongsTo<Guardian, $this>
     */
    public function guardian(): BelongsTo
    {
        return $this->belongsTo(Guardian::class);
    }

    /**
     * @return HasMany<PushDeliveryAttempt, $this>
     */
    public function pushDeliveryAttempts(): HasMany
    {
        return $this->hasMany(PushDeliveryAttempt::class);
    }
}
