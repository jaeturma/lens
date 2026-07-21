<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\V1\SchoolResolverResource;
use App\Http\Responses\ApiResponse;
use App\Models\School;
use Illuminate\Http\JsonResponse;

class ResolveSchoolController extends Controller
{
    public function __invoke(string $publicId): JsonResponse
    {
        $school = School::query()
            ->with('settings')
            ->where('public_id', trim($publicId))
            ->first();

        if (! $school || ! $school->settings) {
            return ApiResponse::error('School ID not found.', [], 404);
        }

        return ApiResponse::success(new SchoolResolverResource($school));
    }
}
