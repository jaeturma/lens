<?php

namespace App\Actions\Attendance;

use App\Enums\StudentStatus;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceRule;
use App\Models\School;
use App\Models\Student;
use Carbon\CarbonImmutable;

class MarkDailyAbsences
{
    /**
     * Mark every active student without an arrival today as absent, once
     * the school's configured absence cutoff has passed. Safe to call
     * repeatedly (e.g. from a frequent schedule) — before the cutoff, on a
     * non-operating day, or with no AttendanceRule configured yet, it does
     * nothing; a student who already has an arrival is never touched.
     *
     * @return int number of students newly marked absent
     */
    public function __invoke(): int
    {
        $school = School::query()->with('settings')->first();

        if (! $school || ! $school->settings) {
            return 0;
        }

        $rule = AttendanceRule::query()->first();

        if (! $rule) {
            return 0;
        }

        $timezone = $school->settings->timezone;
        $today = CarbonImmutable::now($timezone);

        if (! $rule->isOperatingDay($today)) {
            return 0;
        }

        if ($today->lessThan($rule->absenceCutoffFor($today))) {
            return 0;
        }

        $date = $today->toDateString();

        $presentStudentIds = AttendanceDailySummary::query()
            ->whereDate('date', $date)
            ->whereNotNull('arrival_event_id')
            ->pluck('student_id');

        $activeStudentIds = Student::query()->where('status', StudentStatus::Active)->pluck('id');

        $absentStudentIds = $activeStudentIds->diff($presentStudentIds);

        $marked = 0;

        foreach ($absentStudentIds as $studentId) {
            // Same date-cast-column trap WP-04-02 flagged: an array-based
            // where()/updateOrCreate() match against `date` is not reliable,
            // so the row is looked up with whereDate() explicitly.
            $summary = AttendanceDailySummary::query()
                ->where('student_id', $studentId)
                ->whereDate('date', $date)
                ->first();

            if ($summary) {
                if (! $summary->is_absent) {
                    $summary->update(['is_absent' => true]);
                    $marked++;
                }
            } else {
                AttendanceDailySummary::create([
                    'student_id' => $studentId,
                    'date' => $date,
                    'is_absent' => true,
                ]);
                $marked++;
            }
        }

        return $marked;
    }
}
