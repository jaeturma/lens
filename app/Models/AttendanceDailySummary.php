<?php

namespace App\Models;

use App\Observers\AttendanceDailySummaryObserver;
use Database\Factories\AttendanceDailySummaryFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Attributes\ObservedBy;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $student_id
 * @property Carbon $date
 * @property int|null $arrival_event_id
 * @property int|null $departure_event_id
 * @property bool $is_absent
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read Student $student
 * @property-read AttendanceEvent|null $arrivalEvent
 * @property-read AttendanceEvent|null $departureEvent
 */
#[Fillable(['student_id', 'date', 'arrival_event_id', 'departure_event_id', 'is_absent'])]
#[ObservedBy(AttendanceDailySummaryObserver::class)]
class AttendanceDailySummary extends Model
{
    /** @use HasFactory<AttendanceDailySummaryFactory> */
    use HasFactory;

    /**
     * Transient, non-persisted signal for the current save only — a plain
     * typed property, not an Eloquent attribute, so it never affects
     * getDirty()/the UPDATE statement. Set by
     * App\Actions\Attendance\CorrectAttendanceDailySummary right before
     * update() so App\Observers\AttendanceDailySummaryObserver can record
     * SyncChangeAction::Corrected instead of the generic Updated — an
     * ordinary field diff can't tell a correction apart from
     * ProcessRfidScan/MarkDailyAbsences writes, which can land on the same
     * fields.
     */
    public bool $wasCorrected = false;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'date' => 'date',
            'is_absent' => 'boolean',
        ];
    }

    /**
     * @return BelongsTo<Student, $this>
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * @return BelongsTo<AttendanceEvent, $this>
     */
    public function arrivalEvent(): BelongsTo
    {
        return $this->belongsTo(AttendanceEvent::class, 'arrival_event_id');
    }

    /**
     * @return BelongsTo<AttendanceEvent, $this>
     */
    public function departureEvent(): BelongsTo
    {
        return $this->belongsTo(AttendanceEvent::class, 'departure_event_id');
    }
}
