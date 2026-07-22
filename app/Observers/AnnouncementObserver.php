<?php

namespace App\Observers;

use App\Actions\Sync\RecordSyncChange;
use App\Enums\AnnouncementStatus;
use App\Enums\SyncChangeAction;
use App\Models\Announcement;

class AnnouncementObserver
{
    public function __construct(private readonly RecordSyncChange $recordSyncChange) {}

    /**
     * A Draft never enters the sync feed at all — WP-05-01's "drafts are
     * not parent-visible" acceptance criterion, enforced here rather than
     * left to a future guardian-scoping branch that could accidentally
     * expose one. The first sync entry for an announcement is whenever it
     * first becomes non-Draft (see updated()), not necessarily its row's
     * actual creation.
     */
    public function created(Announcement $announcement): void
    {
        if ($announcement->status === AnnouncementStatus::Draft) {
            return;
        }

        ($this->recordSyncChange)($announcement, SyncChangeAction::Created, $this->payload($announcement));
    }

    public function updated(Announcement $announcement): void
    {
        if ($announcement->status === AnnouncementStatus::Draft) {
            return;
        }

        $leftDraft = $announcement->wasChanged('status')
            && $announcement->getOriginal('status') === AnnouncementStatus::Draft;

        $action = match (true) {
            $leftDraft => SyncChangeAction::Created,
            $announcement->wasChanged('status') && $announcement->status === AnnouncementStatus::Withdrawn => SyncChangeAction::Revoked,
            $announcement->wasChanged('status') && $announcement->status === AnnouncementStatus::Expired => SyncChangeAction::Expired,
            default => SyncChangeAction::Updated,
        };

        ($this->recordSyncChange)($announcement, $action, $this->payload($announcement));
    }

    /**
     * @return array<string, mixed>
     */
    private function payload(Announcement $announcement): array
    {
        return [
            'uuid' => $announcement->uuid,
            'title' => $announcement->title,
            'body' => $announcement->body,
            'status' => $announcement->status->value,
            'published_at' => $announcement->published_at?->toIso8601String(),
            'expires_at' => $announcement->expires_at?->toIso8601String(),
        ];
    }
}
