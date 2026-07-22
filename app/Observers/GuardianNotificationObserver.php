<?php

namespace App\Observers;

use App\Actions\Sync\RecordSyncChange;
use App\Enums\SyncChangeAction;
use App\Models\GuardianNotification;

class GuardianNotificationObserver
{
    public function __construct(private readonly RecordSyncChange $recordSyncChange) {}

    public function created(GuardianNotification $notification): void
    {
        ($this->recordSyncChange)($notification, SyncChangeAction::Created, $this->payload($notification));
    }

    /**
     * Covers every update this package's own scope names — read-state
     * toggles and delivery-status changes alike — as the generic Updated
     * action. Which types of updates deserve a more specific action (a
     * tombstone-style one, mirroring how withdrawing an announcement
     * records Revoked) is left to whichever later work package actually
     * wires a guardian-facing endpoint to this model; nothing in this
     * package's own scope calls for one.
     */
    public function updated(GuardianNotification $notification): void
    {
        ($this->recordSyncChange)($notification, SyncChangeAction::Updated, $this->payload($notification));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(GuardianNotification $notification): array
    {
        return [
            'uuid' => $notification->uuid,
            'guardian_id' => $notification->guardian_id,
            'type' => $notification->type->value,
            'title' => $notification->title,
            'body' => $notification->body,
            'payload' => $notification->payload,
            'read_at' => $notification->read_at?->toIso8601String(),
            'delivery_status' => $notification->delivery_status->value,
        ];
    }
}
