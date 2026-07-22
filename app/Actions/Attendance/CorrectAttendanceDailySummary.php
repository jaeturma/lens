<?php

namespace App\Actions\Attendance;

use App\Actions\Audit\RecordAuditLog;
use App\Models\AttendanceDailySummary;
use App\Models\User;

class CorrectAttendanceDailySummary
{
    public function __construct(private readonly RecordAuditLog $recordAuditLog) {}

    /**
     * Correct a daily summary's absence status. Raw scans and their
     * derived AttendanceEvent rows are never touched — only this summary's
     * own fields change.
     *
     * Correcting to absent also clears any recorded arrival/departure link:
     * a summary can't stand as both "absent" and "has an arrival," and an
     * admin asserting absence supersedes whatever scan the summary
     * currently points to. Correcting to present (from an
     * automatically-marked absence) simply flips the flag — there's no
     * real scan to link, so arrival/departure stay null.
     */
    public function __invoke(AttendanceDailySummary $summary, bool $isAbsent, string $reason, ?User $actor = null): AttendanceDailySummary
    {
        $before = [
            'is_absent' => $summary->is_absent,
            'arrival_event_id' => $summary->arrival_event_id,
            'departure_event_id' => $summary->departure_event_id,
        ];

        $attributes = ['is_absent' => $isAbsent];

        if ($isAbsent) {
            $attributes['arrival_event_id'] = null;
            $attributes['departure_event_id'] = null;
        }

        $summary->update($attributes);

        ($this->recordAuditLog)($actor, 'attendance_daily_summary.corrected', $summary, [
            'reason' => $reason,
            'before' => $before,
            'after' => [
                'is_absent' => $summary->is_absent,
                'arrival_event_id' => $summary->arrival_event_id,
                'departure_event_id' => $summary->departure_event_id,
            ],
        ]);

        return $summary;
    }
}
