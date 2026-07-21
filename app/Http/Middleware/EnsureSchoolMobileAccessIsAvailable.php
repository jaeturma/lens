<?php

namespace App\Http\Middleware;

use App\Http\Responses\ApiResponse;
use App\Models\School;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureSchoolMobileAccessIsAvailable
{
    public function handle(Request $request, Closure $next): Response
    {
        $school = School::query()->with('settings')->first();

        if (! $school || ! $school->settings) {
            return ApiResponse::error('School is not configured yet.', [], 503);
        }

        $settings = $school->settings;

        if ($settings->maintenance_mode) {
            return ApiResponse::error(
                $settings->maintenance_message ?: 'The school is under maintenance.',
                [],
                503,
            );
        }

        if (! $settings->mobile_enabled) {
            return ApiResponse::error('Mobile access is currently disabled for this school.', [], 503);
        }

        $appVersion = $request->header('X-App-Version');

        if ($appVersion && version_compare($appVersion, $settings->minimum_app_version, '<')) {
            return ApiResponse::error('Please update the app to continue.', [], 426);
        }

        return $next($request);
    }
}
