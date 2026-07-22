<?php

namespace App\Actions\Notifications;

use App\Enums\GuardianStudentLinkStatus;
use App\Enums\NotificationType;
use App\Models\AttendanceDailySummary;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;
use App\Models\Student;
use InvalidArgumentException;

class NotifyGuardiansOfAttendanceEvent
{
    /**
     * One notification per currently active, notify_attendance-enabled
     * guardian of the summary's student — this is the only place duplicate
     * prevention needs to live, since every caller (ProcessRfidScan,
     * MarkDailyAbsences, CorrectAttendanceDailySummary via
     * AttendanceDailySummaryObserver) already only invokes this at the
     * exact moment a state genuinely changed, never on a repeat/no-op
     * write.
     */
    public function __invoke(AttendanceDailySummary $summary, NotificationType $type): void
    {
        $student = $summary->student;

        // Validated before resolving guardians, not after: a caller
        // passing an unsupported type is a programming error that should
        // surface every time, not only when a qualifying guardian happens
        // to exist.
        [$title, $body] = $this->content($type, $student, $summary);

        $guardianIds = GuardianStudentLink::query()
            ->where('student_id', $student->id)
            ->where('status', GuardianStudentLinkStatus::Active)
            ->pluck('guardian_id');

        $guardians = Guardian::query()
            ->whereIn('id', $guardianIds)
            ->where('notify_attendance', true)
            ->get();

        if ($guardians->isEmpty()) {
            return;
        }

        foreach ($guardians as $guardian) {
            GuardianNotification::create([
                'guardian_id' => $guardian->id,
                'type' => $type,
                'title' => $title,
                'body' => $body,
                'payload' => [
                    'student_id' => $student->id,
                    'attendance_daily_summary_id' => $summary->id,
                    'date' => $summary->date->toDateString(),
                ],
            ]);
        }
    }

    /**
     * @return array{0: string, 1: string}
     */
    private function content(NotificationType $type, Student $student, AttendanceDailySummary $summary): array
    {
        // The correction notification is deliberately generic — it does
        // not repeat the administrator's audit-log reason text, which is
        // internal context (may reference other students, device faults,
        // etc.), not necessarily meant for guardian-facing display.
        return match ($type) {
            NotificationType::Arrival => [
                "{$student->name} has arrived",
                "{$student->name} arrived at school.",
            ],
            NotificationType::Late => [
                "{$student->name} arrived late",
                "{$student->name} arrived at school after the arrival cutoff.",
            ],
            NotificationType::Departure => [
                "{$student->name} has departed",
                "{$student->name} left school.",
            ],
            NotificationType::Absence => [
                "{$student->name} is absent today",
                "{$student->name} has no recorded arrival for {$summary->date->toDateString()}.",
            ],
            NotificationType::Correction => [
                "Attendance corrected for {$student->name}",
                "{$student->name}'s attendance record for {$summary->date->toDateString()} was corrected by school staff.",
            ],
            NotificationType::AnnouncementPublished => throw new InvalidArgumentException(
                'NotifyGuardiansOfAttendanceEvent does not handle AnnouncementPublished — that is a separate, non-attendance notification (WP-06-03).',
            ),
        };
    }
}
