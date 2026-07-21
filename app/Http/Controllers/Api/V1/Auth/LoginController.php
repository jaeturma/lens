<?php

namespace App\Http\Controllers\Api\V1\Auth;

use App\Enums\GuardianStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\MobileLoginRequest;
use App\Http\Resources\V1\UserResource;
use App\Http\Responses\ApiResponse;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    public function __invoke(MobileLoginRequest $request): JsonResponse
    {
        $credentials = $request->validated();

        $user = User::where('email', $credentials['email'])->first();

        if (! $user || ! Hash::check($credentials['password'], $user->password)) {
            throw ValidationException::withMessages([
                'email' => 'These credentials do not match our records.',
            ]);
        }

        if (! $user->isGuardian()) {
            return ApiResponse::error('This account is not enabled for mobile login.', [], 403);
        }

        if ($user->guardian && $user->guardian->status === GuardianStatus::Inactive) {
            return ApiResponse::error('This account is inactive. Please contact the school.', [], 403);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return ApiResponse::success([
            'token' => $token,
            'user' => new UserResource($user),
        ], 'Login successful.');
    }
}
