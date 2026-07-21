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
        ($this->recordSyncChange)($summary, SyncChangeAction::Updated, $this->payload($summary));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(AttendanceDailySummary $summary): array
    {
        return [
            'student_id' => $summary->student_id,
            'date' => $summary->date->toDateString(),
            'arrival' => $summary->arrivalEvent?->occurred_at->toIso8601String(),
            'departure' => $summary->departureEvent?->occurred_at->toIso8601String(),
        ];
    }
}
