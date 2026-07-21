<?php

namespace App\Http\Controllers\Students;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\StudentStatus;
use App\Http\Controllers\Controller;
use App\Models\Student;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;

class DeactivateStudentController extends Controller
{
    public function __invoke(Request $request, Student $student, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $this->authorize('update', $student);

        $student->update(['status' => StudentStatus::Inactive]);

        $recordAuditLog($request->user(), 'student.deactivated', $student);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Student deactivated.']);

        return back();
    }
}
