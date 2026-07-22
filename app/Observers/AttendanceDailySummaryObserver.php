<?php

namespace App\Observers;

use App\Actions\Notifications\NotifyGuardiansOfAttendanceEvent;
use App\Actions\Sync\RecordSyncChange;
use App\Enums\NotificationType;
use App\Enums\SyncChangeAction;
use App\Models\AttendanceDailySummary;

class AttendanceDailySummaryObserver
{
    public function __construct(
        private readonly RecordSyncChange $recordSyncChange,
        private readonly NotifyGuardiansOfAttendanceEvent $notifyGuardiansOfAttendanceEvent,
    ) {}

    public function created(AttendanceDailySummary $summary): void
    {
        ($this->recordSyncChange)($summary, SyncChangeAction::Created, $this->payload($summary));

        // A brand-new summary can already carry a winning arrival/departure
        // (first-ever record for this student) or an absence mark (no
        // prior summary existed when MarkDailyAbsences ran) — there is no
        // "changed from" state to compare against on creation, so these
        // are checked directly rather than via wasChanged().
        if ($summary->arrival_event_id !== null) {
            $this->notifyArrivalOrLate($summary);
        }
        if ($summary->departure_event_id !== null) {
            ($this->notifyGuardiansOfAttendanceEvent)($summary, NotificationType::Departure);
        }
        if ($summary->is_absent) {
            ($this->notifyGuardiansOfAttendanceEvent)($summary, NotificationType::Absence);
        }
    }

    public function updated(AttendanceDailySummary $summary): void
    {
        $wasCorrected = $summary->wasCorrected;
        $action = $wasCorrected ? SyncChangeAction::Corrected : SyncChangeAction::Updated;

        // Reset immediately: this model instance may be updated again later
        // in the same request/test (e.g. a subsequent ordinary save), and
        // the flag must not leak into that unrelated write.
        $summary->wasCorrected = false;

        ($this->recordSyncChange)($summary, $action, $this->payload($summary));

        // A correction supersedes arrival/departure/absence classification
        // entirely — an administrator changing is_absent (the only
        // correctable field, and it always also clears/leaves cleared
        // arrival/departure when set true — WP-04-05) is never also "a new
        // arrival" or "a new absence" from the guardian's point of view,
        // it is specifically a correction. Only fires when something
        // guardian-visible actually changed, so a no-op correction (same
        // value re-applied) stays silent — "corrections where appropriate."
        if ($wasCorrected) {
            if ($summary->wasChanged(['is_absent', 'arrival_event_id', 'departure_event_id'])) {
                ($this->notifyGuardiansOfAttendanceEvent)($summary, NotificationType::Correction);
            }

            return;
        }

        if ($summary->wasChanged('arrival_event_id') && $summary->getOriginal('arrival_event_id') === null && $summary->arrival_event_id !== null) {
            $this->notifyArrivalOrLate($summary);
        }
        if ($summary->wasChanged('departure_event_id') && $summary->departure_event_id !== null) {
            ($this->notifyGuardiansOfAttendanceEvent)($summary, NotificationType::Departure);
        }
        if ($summary->wasChanged('is_absent') && $summary->is_absent) {
            ($this->notifyGuardiansOfAttendanceEvent)($summary, NotificationType::Absence);
        }
    }

    private function notifyArrivalOrLate(AttendanceDailySummary $summary): void
    {
        $summary->loadMissing('arrivalEvent');
        $type = ($summary->arrivalEvent && $summary->arrivalEvent->is_late) ? NotificationType::Late : NotificationType::Arrival;

        ($this->notifyGuardiansOfAttendanceEvent)($summary, $type);
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(AttendanceDailySummary $summary): array
    {
        // Force a fresh reload rather than the cached property accessor:
        // the same $summary instance can be created then updated again
        // within one request (e.g. a correction right after creation), and
        // a stale cached relation — even a cached "null" from before
        // arrival_event_id was set — would silently produce a wrong payload.
        $summary->load(['arrivalEvent', 'departureEvent']);

        return [
            'student_id' => $summary->student_id,
            'date' => $summary->date->toDateString(),
            'arrival' => $summary->arrivalEvent?->occurred_at->toIso8601String(),
            'departure' => $summary->departureEvent?->occurred_at->toIso8601String(),
            'is_late' => $summary->arrivalEvent ? $summary->arrivalEvent->is_late : false,
            'is_absent' => $summary->is_absent,
        ];
    }
}
