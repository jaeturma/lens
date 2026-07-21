<?php

use App\Http\Controllers\Students\ActivateStudentController;
use App\Http\Controllers\Students\DeactivateStudentController;
use App\Http\Controllers\Students\StudentController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('students', StudentController::class)->except('destroy');

    Route::patch('students/{student}/activate', ActivateStudentController::class)->name('students.activate');
    Route::patch('students/{student}/deactivate', DeactivateStudentController::class)->name('students.deactivate');
});
