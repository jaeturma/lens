<?php

namespace App\Actions\Announcements;

use App\Enums\AnnouncementStatus;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Models\Announcement;

class ExpireAnnouncement
{
    /**
     * Manual, admin-triggered expiration of one specific announcement —
     * distinct from App\Actions\Announcements\ExpireDueAnnouncements
     * (WP-05-01), which bulk-expires every Published announcement whose
     * expires_at has already passed. This lets an administrator retire an
     * announcement early, with or without an expires_at ever being set.
     * Only a Published announcement can be expired, same terminal-state
     * rule as WithdrawAnnouncement.
     */
    public function __invoke(Announcement $announcement): Announcement
    {
        if ($announcement->status !== AnnouncementStatus::Published) {
            throw new InvalidAnnouncementTransitionException($announcement->status, AnnouncementStatus::Expired);
        }

        $announcement->update(['status' => AnnouncementStatus::Expired]);

        return $announcement;
    }
}
