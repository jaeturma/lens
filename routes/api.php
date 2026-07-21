<?php

use App\Http\Controllers\Api\V1\Auth\LoginController;
use App\Http\Controllers\Api\V1\Auth\LogoutController;
use App\Http\Controllers\Api\V1\Auth\MeController;
use App\Http\Controllers\Api\V1\HealthController;
use App\Http\Controllers\Api\V1\ResolveSchoolController;
use App\Http\Controllers\Api\V1\Sync\BootstrapController;
use App\Http\Controllers\Api\V1\Sync\ChangesController;
use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    Route::get('health', HealthController::class);

    Route::get('schools/resolve/{publicId}', ResolveSchoolController::class)
        ->where('publicId', '[A-Za-z0-9\-]{1,64}')
        ->middleware('throttle:school-resolver');

    Route::prefix('auth')->group(function (): void {
        Route::post('login', LoginController::class)
            ->middleware(['school.mobile', 'throttle:mobile-login']);

        Route::middleware('auth:sanctum')->group(function (): void {
            Route::get('me', MeController::class);
            Route::post('logout', LogoutController::class);
        });
    });

    Route::prefix('sync')->middleware(['auth:sanctum', 'school.mobile', 'throttle:sync'])->group(function (): void {
        Route::get('bootstrap', BootstrapController::class);
        Route::get('changes', ChangesController::class);
    });
});
