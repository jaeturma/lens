<?php

namespace App\Actions\Announcements;

use App\Enums\AnnouncementStatus;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Models\Announcement;

class WithdrawAnnouncement
{
    /**
     * Only a Published announcement can be withdrawn — a Draft was never
     * visible to withdraw, and Expired/Withdrawn are terminal. Withdrawing
     * doesn't touch published_at (it stays as a record of when it first
     * went live).
     */
    public function __invoke(Announcement $announcement): Announcement
    {
        if ($announcement->status !== AnnouncementStatus::Published) {
            throw new InvalidAnnouncementTransitionException($announcement->status, AnnouncementStatus::Withdrawn);
        }

        $announcement->update(['status' => AnnouncementStatus::Withdrawn]);

        return $announcement;
    }
}
