<?php

use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\ResolveSchoolController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('health', HealthController::class);

    Route::get('schools/resolve/{publicId}', ResolveSchoolController::class)
        ->where('publicId', '[A-Za-z0-9\-]{1,64}')
        ->middleware('throttle:school-resolver');
});
