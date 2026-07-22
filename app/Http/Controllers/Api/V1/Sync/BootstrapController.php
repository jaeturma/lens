<?php

namespace App\Http\Controllers\Api\V1\Sync;

use App\Actions\Announcements\GuardianMatchesAnnouncementAudience;
use App\Actions\Sync\CurrentSyncCursor;
use App\Enums\AnnouncementStatus;
use App\Http\Controllers\Controller;
use App\Http\Resources\V1\BootstrapResource;
use App\Http\Responses\ApiResponse;
use App\Models\Announcement;
use App\Models\School;
use App\Models\User;
use Carbon\CarbonImmutable;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class BootstrapController extends Controller
{
    public function __invoke(Request $request, CurrentSyncCursor $currentSyncCursor, GuardianMatchesAnnouncementAudience $guardianMatchesAnnouncementAudience): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if (! $user->isGuardian()) {
            return ApiResponse::error('This account is not enabled for mobile synchronization.', [], 403);
        }

        $school = School::query()->with('settings')->first();
        $guardian = $user->guardian;
        $timezone = ($school && $school->settings) ? $school->settings->timezone : 'UTC';
        $today = CarbonImmutable::now($timezone)->toDateString();

        $children = $guardian
            ? $guardian->activeLinks()->with([
                'student.attendanceSummaries' => fn ($query) => $query
                    ->whereDate('date', $today)
                    ->with(['arrivalEvent', 'departureEvent']),
            ])->get()
            : new Collection;

        $announcements = $guardian
            ? Announcement::query()
                ->where('status', AnnouncementStatus::Published)
                ->get()
                ->filter(fn (Announcement $announcement) => $guardianMatchesAnnouncementAudience($announcement, $guardian))
                ->values()
            : new Collection;

        return ApiResponse::success(new BootstrapResource((object) [
            'school' => $school,
            'user' => $user,
            'guardian' => $guardian,
            'children' => $children,
            'announcements' => $announcements,
            'next_cursor' => (string) $currentSyncCursor(),
        ]));
    }
}
