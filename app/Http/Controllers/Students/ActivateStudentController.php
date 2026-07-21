<?php

namespace App\Http\Controllers\Students;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\StudentStatus;
use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ActivateStudentController extends Controller
{
    public function __invoke(Request $request, Student $student, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $this->authorize('update', $student);

        $student->update(['status' => StudentStatus::Active]);

        $recordAuditLog($request->user(), 'student.activated', $student);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Student activated.']);

        return back();
    }
}
