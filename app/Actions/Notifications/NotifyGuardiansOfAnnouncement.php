<?php

namespace App\Actions\Notifications;

use App\Actions\Announcements\ResolveAnnouncementAudience;
use App\Enums\GuardianStudentLinkStatus;
use App\Enums\NotificationType;
use App\Models\Announcement;
use App\Models\Guardian;
use App\Models\GuardianNotification;
use App\Models\GuardianStudentLink;

class NotifyGuardiansOfAnnouncement
{
    public function __construct(private readonly ResolveAnnouncementAudience $resolveAnnouncementAudience) {}

    /**
     * One notification per currently active, notify_announcements-enabled
     * guardian whose audience matches — deduplicated per guardian, not per
     * (guardian, student) pair: an announcement's content is the same
     * regardless of which of a guardian's several children it matched
     * through, so a guardian with two matching children still gets
     * exactly one notification, not two.
     *
     * The caller (App\Observers\AnnouncementObserver) only invokes this at
     * the Draft → Published transition — never on a later edit to an
     * already-Published announcement, even one that changes the audience.
     * "Republish," decided as this package's own scope item: editing a
     * Published announcement never sends additional notifications, in
     * either direction (a widened audience doesn't backfill newly-matching
     * guardians, a narrowed one doesn't retract anything already sent). An
     * administrator who wants to reach a different or wider audience
     * withdraws and creates a new announcement instead — the same
     * "resurrecting isn't supported, a new one is" precedent WP-05-01 set
     * for the Withdrawn/Expired terminal states themselves.
     */
    public function __invoke(Announcement $announcement): void
    {
        $studentIds = ($this->resolveAnnouncementAudience)($announcement);

        $guardianIds = GuardianStudentLink::query()
            ->whereIn('student_id', $studentIds)
            ->where('status', GuardianStudentLinkStatus::Active)
            ->pluck('guardian_id')
            ->unique();

        $guardians = Guardian::query()
            ->whereIn('id', $guardianIds)
            ->where('notify_announcements', true)
            ->get();

        foreach ($guardians as $guardian) {
            GuardianNotification::create([
                'guardian_id' => $guardian->id,
                'type' => NotificationType::AnnouncementPublished,
                'title' => $announcement->title,
                'body' => $announcement->body,
                'payload' => [
                    'announcement_id' => $announcement->id,
                    'announcement_uuid' => $announcement->uuid,
                ],
            ]);
        }
    }
}
