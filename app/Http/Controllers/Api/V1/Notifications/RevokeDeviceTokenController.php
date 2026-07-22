<?php

namespace App\Http\Controllers\Api\V1\Notifications;

use App\Actions\Notifications\RevokeDeviceToken;
use App\Http\Controllers\Controller;
use App\Http\Requests\Notifications\RevokeDeviceTokenRequest;
use App\Http\Responses\ApiResponse;
use App\Models\DeviceToken;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class RevokeDeviceTokenController extends Controller
{
    public function __invoke(RevokeDeviceTokenRequest $request, RevokeDeviceToken $revokeDeviceToken): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if (! $user->isGuardian() || ! $user->guardian) {
            return ApiResponse::error('This account is not enabled for mobile synchronization.', [], 403);
        }

        $deviceToken = DeviceToken::query()
            ->where('token', $request->validated('token'))
            ->where('guardian_id', $user->guardian->id)
            ->first();

        if (! $deviceToken) {
            return ApiResponse::error('Device token not found.', [], 404);
        }

        $revokeDeviceToken($deviceToken);

        return ApiResponse::success([], 'Device token revoked.');
    }
}
