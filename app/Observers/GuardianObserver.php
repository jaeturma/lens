<?php

namespace App\Observers;

use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\Guardian;

class GuardianObserver
{
    public function __construct(private readonly RecordSyncChange $recordSyncChange) {}

    public function created(Guardian $guardian): void
    {
        ($this->recordSyncChange)($guardian, SyncChangeAction::Created, $this->payload($guardian));
    }

    public function updated(Guardian $guardian): void
    {
        ($this->recordSyncChange)($guardian, SyncChangeAction::Updated, $this->payload($guardian));
    }

    public function deleted(Guardian $guardian): void
    {
        ($this->recordSyncChange)($guardian, SyncChangeAction::Deleted, $this->payload($guardian));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Guardian $guardian): array
    {
        return [
            'uuid' => $guardian->uuid,
            'name' => $guardian->name,
            'email' => $guardian->email,
            'mobile_number' => $guardian->mobile_number,
            'status' => $guardian->status->value,
            'notify_attendance' => $guardian->notify_attendance,
            'notify_announcements' => $guardian->notify_announcements,
        ];
    }
}
