<?php

use App\Http\Controllers\Guardians\ActivateGuardianController;
use App\Http\Controllers\Guardians\DeactivateGuardianController;
use App\Http\Controllers\Guardians\GuardianController;
use App\Http\Controllers\Guardians\RevokeGuardianStudentLinkController;
use App\Http\Controllers\Guardians\StoreGuardianStudentLinkController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('guardians', GuardianController::class)->except('destroy');

    Route::patch('guardians/{guardian}/activate', ActivateGuardianController::class)->name('guardians.activate');
    Route::patch('guardians/{guardian}/deactivate', DeactivateGuardianController::class)->name('guardians.deactivate');

    Route::post('guardians/{guardian}/links', StoreGuardianStudentLinkController::class)->name('guardians.links.store');
    Route::patch('guardians/{guardian}/links/{link}/revoke', RevokeGuardianStudentLinkController::class)->name('guardians.links.revoke');
});
