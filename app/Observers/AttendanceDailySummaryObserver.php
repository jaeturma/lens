<?php

namespace App\Observers;

use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\AttendanceDailySummary;

class AttendanceDailySummaryObserver
{
    public function __construct(private readonly RecordSyncChange $recordSyncChange) {}

    public function created(AttendanceDailySummary $summary): void
    {
        ($this->recordSyncChange)($summary, SyncChangeAction::Created, $this->payload($summary));
    }

    public function updated(AttendanceDailySummary $summary): void
    {
        $action = $summary->wasCorrected ? SyncChangeAction::Corrected : SyncChangeAction::Updated;

        // Reset immediately: this model instance may be updated again later
        // in the same request/test (e.g. a subsequent ordinary save), and
        // the flag must not leak into that unrelated write.
        $summary->wasCorrected = false;

        ($this->recordSyncChange)($summary, $action, $this->payload($summary));
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
