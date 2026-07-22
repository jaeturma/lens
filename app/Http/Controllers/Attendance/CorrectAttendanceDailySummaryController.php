<?php

namespace App\Http\Controllers\Attendance;

use App\Actions\Attendance\CorrectAttendanceDailySummary;
use App\Http\Controllers\Controller;
use App\Http\Requests\Attendance\CorrectAttendanceDailySummaryRequest;
use App\Models\AttendanceDailySummary;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;

class CorrectAttendanceDailySummaryController extends Controller
{
    public function __invoke(
        CorrectAttendanceDailySummaryRequest $request,
        AttendanceDailySummary $summary,
        CorrectAttendanceDailySummary $correctAttendanceDailySummary,
    ): RedirectResponse {
        $correctAttendanceDailySummary(
            $summary,
            $request->boolean('is_absent'),
            $request->validated('reason'),
            $request->user(),
        );

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Attendance corrected.']);

        return back();
    }
}
