<?php

namespace App\Models;

use App\Enums\AttendanceEventType;
use Database\Factories\AttendanceEventFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $rfid_scan_id
 * @property int $student_id
 * @property int $rfid_device_id
 * @property AttendanceEventType $event_type
 * @property Carbon $occurred_at
 * @property Carbon $created_at
 * @property-read RfidScan $rfidScan
 * @property-read Student $student
 * @property-read RfidDevice $device
 */
#[Fillable(['rfid_scan_id', 'student_id', 'rfid_device_id', 'event_type', 'occurred_at'])]
class AttendanceEvent extends Model
{
    /** @use HasFactory<AttendanceEventFactory> */
    use HasFactory;

    const UPDATED_AT = null;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'event_type' => AttendanceEventType::class,
            'occurred_at' => 'datetime',
            'created_at' => 'datetime',
        ];
    }

    /**
     * @return BelongsTo<RfidScan, $this>
     */
    public function rfidScan(): BelongsTo
    {
        return $this->belongsTo(RfidScan::class);
    }

    /**
     * @return BelongsTo<Student, $this>
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * @return BelongsTo<RfidDevice, $this>
     */
    public function device(): BelongsTo
    {
        return $this->belongsTo(RfidDevice::class, 'rfid_device_id');
    }
}
