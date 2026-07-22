<?php

namespace App\Actions\Announcements;

use App\Enums\AnnouncementStatus;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Models\Announcement;
use Carbon\CarbonImmutable;

class PublishAnnouncement
{
    /**
     * Only a Draft can be published. published_at is recorded as of now,
     * not admin-settable — this is when it actually went live, not a
     * future scheduling mechanism (out of scope, not asked for).
     */
    public function __invoke(Announcement $announcement): Announcement
    {
        if ($announcement->status !== AnnouncementStatus::Draft) {
            throw new InvalidAnnouncementTransitionException($announcement->status, AnnouncementStatus::Published);
        }

        $announcement->update([
            'status' => AnnouncementStatus::Published,
            'published_at' => CarbonImmutable::now(),
        ]);

        return $announcement;
    }
}
