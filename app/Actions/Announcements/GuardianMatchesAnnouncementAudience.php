<?php

namespace App\Actions\Announcements;

use App\Models\Announcement;
use App\Models\Guardian;

class GuardianMatchesAnnouncementAudience
{
    public function __construct(private readonly ResolveAnnouncementAudience $resolveAnnouncementAudience) {}

    /**
     * Whether at least one of the guardian's currently active linked
     * students falls within the announcement's audience. A revoked link's
     * student is never in Guardian::activeLinks(), so revoking a link
     * stops matching immediately — the same "currently active" rule
     * App\Actions\Sync\ScopeChangesToGuardian already applies for
     * attendance (WP-04-06). This checks audience membership only, not
     * the announcement's status — pairing it with a Published-only check
     * is the caller's job (the eventual guardian-facing sync contract,
     * WP-05-04).
     */
    public function __invoke(Announcement $announcement, Guardian $guardian): bool
    {
        $audienceStudentIds = ($this->resolveAnnouncementAudience)($announcement);
        $activeLinkedStudentIds = $guardian->activeLinks()->pluck('student_id');

        return $audienceStudentIds->intersect($activeLinkedStudentIds)->isNotEmpty();
    }
}
