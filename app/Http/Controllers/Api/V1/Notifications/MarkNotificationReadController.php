<?php

namespace App\Http\Controllers\Api\V1\Notifications;

use App\Actions\Notifications\MarkNotificationRead;
use App\Http\Controllers\Controller;
use App\Http\Responses\ApiResponse;
use App\Models\GuardianNotification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MarkNotificationReadController extends Controller
{
    public function __invoke(Request $request, string $uuid, MarkNotificationRead $markNotificationRead): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if (! $user->isGuardian() || ! $user->guardian) {
            return ApiResponse::error('This account is not enabled for mobile synchronization.', [], 403);
        }

        $notification = GuardianNotification::query()
            ->where('uuid', $uuid)
            ->where('guardian_id', $user->guardian->id)
            ->first();

        if (! $notification) {
            return ApiResponse::error('Notification not found.', [], 404);
        }

        $markNotificationRead($notification);

        return ApiResponse::success([], 'Notification marked as read.');
    }
}
