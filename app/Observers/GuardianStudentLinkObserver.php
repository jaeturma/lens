<?php

namespace App\Observers;

use App\Actions\Sync\RecordSyncChange;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\SyncChangeAction;
use App\Models\GuardianStudentLink;

class GuardianStudentLinkObserver
{
    public function __construct(private readonly RecordSyncChange $recordSyncChange) {}

    public function created(GuardianStudentLink $link): void
    {
        ($this->recordSyncChange)($link, SyncChangeAction::Created, $this->payload($link));
    }

    public function updated(GuardianStudentLink $link): void
    {
        $action = $link->wasChanged('status') && $link->status === GuardianStudentLinkStatus::Revoked
            ? SyncChangeAction::Revoked
            : SyncChangeAction::Updated;

        ($this->recordSyncChange)($link, $action, $this->payload($link));
    }

    public function deleted(GuardianStudentLink $link): void
    {
        ($this->recordSyncChange)($link, SyncChangeAction::Deleted, $this->payload($link));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(GuardianStudentLink $link): array
    {
        return [
            'uuid' => $link->uuid,
            'student_id' => $link->student_id,
            'guardian_id' => $link->guardian_id,
            'relationship_type' => $link->relationship_type->value,
            'is_primary_contact' => $link->is_primary_contact,
            'status' => $link->status->value,
            'notifications_enabled' => $link->notifications_enabled,
        ];
    }
}
