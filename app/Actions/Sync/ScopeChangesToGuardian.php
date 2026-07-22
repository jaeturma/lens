<?php

namespace App\Actions\Sync;

use App\Models\Guardian;
use App\Models\SyncChange;
use Illuminate\Support\Collection;

class ScopeChangesToGuardian
{
    /**
     * Filter a page of sync changes to what one guardian may see.
     *
     * @param  Collection<int, SyncChange>  $changes
     * @return Collection<int, SyncChange>
     */
    public function __invoke(Collection $changes, ?Guardian $guardian): Collection
    {
        $activeStudentIds = $guardian?->activeLinks()->pluck('student_id')->all() ?? [];
        $ownLinkIds = $guardian?->links()->pluck('id')->all() ?? [];

        return $changes->filter(function (SyncChange $change) use ($guardian, $activeStudentIds, $ownLinkIds) {
            return match ($change->resource_type) {
                'school' => true,
                'student' => in_array($change->resource_id, $activeStudentIds, true),
                'guardian' => $guardian !== null && $change->resource_id === $guardian->id,
                'guardian_student_link' => in_array($change->resource_id, $ownLinkIds, true),
                // The summary's own resource_id isn't the student — it's
                // scoped by the student_id carried in its payload instead,
                // same "currently active" rule as `student` entries.
                'attendance_daily_summary' => in_array($change->payload['student_id'] ?? null, $activeStudentIds, true),
                default => false,
            };
        })->values();
    }
}
