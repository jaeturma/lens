<?php

namespace App\Models;

use App\Enums\RfidScanClassification;
use App\Observers\RfidScanObserver;
use Database\Factories\RfidScanFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $rfid_device_id
 * @property string $uid
 * @property Carbon $device_timestamp
 * @property string $request_id
 * @property RfidScanClassification $classification
 * @property Carbon $created_at
 * @property-read RfidDevice $device
 * @property-read AttendanceEvent|null $attendanceEvent
 */
#[Fillable(['rfid_device_id', 'uid', 'device_timestamp', 'request_id', 'classification'])]
#[ObservedBy(RfidScanObserver::class)]
class RfidScan extends Model
{
    /** @use HasFactory<RfidScanFactory> */
    use HasFactory;

    const UPDATED_AT = null;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'device_timestamp' => 'datetime',
            'classification' => RfidScanClassification::class,
            'created_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<RfidDevice, $this>
     */
    public function device(): BelongsTo
    {
        return $this->belongsTo(RfidDevice::class, 'rfid_device_id');
    }

    /**
     * @return HasOne<AttendanceEvent, $this>
     */
    public function attendanceEvent(): HasOne
    {
        return $this->hasOne(AttendanceEvent::class);
    }
}
