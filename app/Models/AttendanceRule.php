<?php

namespace App\Models;

use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;
use Database\Factories\AttendanceRuleFactory;
use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Carbon;

/**
 * @property int $id
 * @property int $school_id
 * @property array<int, int> $operating_days
 * @property string $arrival_cutoff_time
 * @property string $departure_time
 * @property string $absence_cutoff_time
 * @property int $duplicate_window_seconds
 * @property Carbon|null $created_at
 * @property Carbon|null $updated_at
 * @property-read School $school
 */
#[Fillable(['school_id', 'operating_days', 'arrival_cutoff_time', 'departure_time', 'absence_cutoff_time', 'duplicate_window_seconds'])]
class AttendanceRule extends Model
{
    /** @use HasFactory<AttendanceRuleFactory> */
    use HasFactory;

    /**
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'operating_days' => 'array',
            'duplicate_window_seconds' => 'integer',
        ];
    }

    /**
     * @return BelongsTo<School, $this>
     */
    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    public function isOperatingDay(CarbonInterface $date): bool
    {
        return in_array($date->dayOfWeekIso, $this->operating_days, true);
    }

    public function arrivalCutoffFor(CarbonInterface $date): CarbonImmutable
    {
        return $this->combine($date, $this->arrival_cutoff_time);
    }

    public function departureTimeFor(CarbonInterface $date): CarbonImmutable
    {
        return $this->combine($date, $this->departure_time);
    }

    public function absenceCutoffFor(CarbonInterface $date): CarbonImmutable
    {
        return $this->combine($date, $this->absence_cutoff_time);
    }

    /**
     * Combine a calendar date with a stored HH:MM:SS time, interpreted in
     * the school's configured timezone (never UTC or server-local time).
     */
    private function combine(CarbonInterface $date, string $time): CarbonImmutable
    {
        $timezone = $this->school->settings->timezone;

        return CarbonImmutable::parse($date->format('Y-m-d').' '.$time, $timezone);
    }
}
