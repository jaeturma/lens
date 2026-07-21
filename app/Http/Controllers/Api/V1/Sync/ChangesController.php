<?php

namespace App\Http\Controllers\Api\V1\Sync;

use App\Actions\Sync\FetchSyncChanges;
use App\Actions\Sync\ScopeChangesToGuardian;
use App\Http\Controllers\Controller;
use App\Http\Requests\Sync\SyncChangesRequest;
use App\Http\Resources\V1\SyncChangesResource;
use App\Http\Responses\ApiResponse;
use App\Models\User;
use App\Support\Sync\SyncCursor;
use Illuminate\Http\JsonResponse;

class ChangesController extends Controller
{
    public function __invoke(SyncChangesRequest $request, FetchSyncChanges $fetchSyncChanges, ScopeChangesToGuardian $scopeChangesToGuardian): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if (! $user->isGuardian()) {
            return ApiResponse::error('This account is not enabled for mobile synchronization.', [], 403);
        }

        $validated = $request->validated();
        $cursor = SyncCursor::fromString($validated['cursor']);
        $limit = (int) ($validated['limit'] ?? 100);

        $page = $fetchSyncChanges($cursor, $limit);
        $changes = $scopeChangesToGuardian($page->changes, $user->guardian);

        return ApiResponse::success(new SyncChangesResource((object) [
            'next_cursor' => (string) $page->nextCursor,
            'has_more' => $page->hasMore,
            'changes' => $changes,
        ]));
    }
}
