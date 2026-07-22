<?php

namespace App\Actions\Announcements;

use App\Enums\AnnouncementStatus;
use App\Models\Announcement;
use Carbon\CarbonImmutable;

class ExpireDueAnnouncements
{
    /**
     * Transition every Published announcement whose expires_at has passed
     * to Expired. Only Published announcements are ever considered — a
     * Draft has no meaningful expiration, and Withdrawn/Expired are
     * already terminal. Updated one row at a time (not a bulk query
     * UPDATE) so AnnouncementObserver still fires per row and records the
     * sync change each expiration produces.
     *
     * @return int number of announcements newly expired
     */
    public function __invoke(): int
    {
        $due = Announcement::query()
            ->where('status', AnnouncementStatus::Published)
            ->whereNotNull('expires_at')
            ->where('expires_at', '<=', CarbonImmutable::now())
            ->get();

        foreach ($due as $announcement) {
            $announcement->update(['status' => AnnouncementStatus::Expired]);
        }

        return $due->count();
    }
}
