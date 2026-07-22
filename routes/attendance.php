<?php

use App\Http\Controllers\Attendance\CorrectAttendanceDailySummaryController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::patch('attendance/daily-summaries/{summary}/correct', CorrectAttendanceDailySummaryController::class)
        ->name('attendance.daily-summaries.correct');
});
