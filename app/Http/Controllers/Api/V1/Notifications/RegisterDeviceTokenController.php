<?php

namespace App\Http\Controllers\Api\V1\Notifications;

use App\Actions\Notifications\RegisterDeviceToken;
use App\Http\Controllers\Controller;
use App\Http\Requests\Notifications\RegisterDeviceTokenRequest;
use App\Http\Responses\ApiResponse;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class RegisterDeviceTokenController extends Controller
{
    public function __invoke(RegisterDeviceTokenRequest $request, RegisterDeviceToken $registerDeviceToken): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();

        if (! $user->isGuardian()) {
            return ApiResponse::error('This account is not enabled for mobile synchronization.', [], 403);
        }

        if (! $user->guardian) {
            return ApiResponse::error('This account has no guardian profile yet.', [], 403);
        }

        $validated = $request->validated();

        $registerDeviceToken($user->guardian, $validated['token'], $validated['previous_token'] ?? null);

        return ApiResponse::success([], 'Device token registered.');
    }
}
