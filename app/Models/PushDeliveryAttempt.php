<?php

namespace App\Models;

use Database\Factories\PushDeliveryAttemptFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * One row per App\Jobs\SendPushSignal execution (WP-06-05), including
 * retries — "log push attempts." Append-only, same pattern as
 * App\Models\AuditLog/AttendanceEvent.
 *
 * @property int $id
 * @property int $guardian_notification_id
 * @property int $attempt_number
 * @property bool $succeeded
 * @property string|null $error_message
 * @property Carbon $created_at
 * @property-read GuardianNotification $guardianNotification
 */
#[Fillable(['guardian_notification_id', 'attempt_number', 'succeeded', 'error_message'])]
class PushDeliveryAttempt extends Model
{
    /** @use HasFactory<PushDeliveryAttemptFactory> */
    use HasFactory;

    const UPDATED_AT = null;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'succeeded' => 'boolean',
            'created_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<GuardianNotification, $this>
     */
    public function guardianNotification(): BelongsTo
    {
        return $this->belongsTo(GuardianNotification::class);
    }
}
