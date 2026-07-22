<?php

namespace App\Actions\Announcements;

use App\Enums\AnnouncementAudienceType;
use App\Enums\StudentStatus;
use App\Models\Announcement;
use App\Models\Student;
use Illuminate\Support\Collection;

class ResolveAnnouncementAudience
{
    /**
     * Resolve an announcement's audience to the set of active student IDs
     * it targets — pure audience matching, independent of the
     * announcement's own lifecycle status (a Draft resolves an audience
     * just as well as a Published one; whether it's actually
     * distributable at all is a separate concern, not this action's job).
     * Every audience type is filtered to StudentStatus::Active only,
     * including Students (an explicitly selected but since-withdrawn
     * student's guardian is not targeted), so behavior is consistent
     * across all four types.
     *
     * @return Collection<int, int>
     */
    public function __invoke(Announcement $announcement): Collection
    {
        return match ($announcement->audience_type) {
            AnnouncementAudienceType::All => Student::query()
                ->where('status', StudentStatus::Active)
                ->pluck('id'),

            AnnouncementAudienceType::Grade => Student::query()
                ->where('status', StudentStatus::Active)
                ->where('grade', $announcement->audience_grade)
                ->pluck('id'),

            AnnouncementAudienceType::Section => Student::query()
                ->where('status', StudentStatus::Active)
                ->where('grade', $announcement->audience_grade)
                ->where('section', $announcement->audience_section)
                ->pluck('id'),

            AnnouncementAudienceType::Students => $announcement->students()
                ->where('status', StudentStatus::Active)
                ->pluck('students.id'),
        };
    }
}
