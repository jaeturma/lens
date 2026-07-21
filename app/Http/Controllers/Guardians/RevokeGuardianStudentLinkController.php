<?php

namespace App\Http\Controllers\Guardians;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\GuardianStudentLinkStatus;
use App\Http\Controllers\Controller;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class RevokeGuardianStudentLinkController extends Controller
{
    public function __invoke(Request $request, Guardian $guardian, GuardianStudentLink $link, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $this->authorize('update', $guardian);

        if ($link->guardian_id !== $guardian->id) {
            throw new NotFoundHttpException;
        }

        $link->update(['status' => GuardianStudentLinkStatus::Revoked]);

        $recordAuditLog($request->user(), 'guardian_student_link.revoked', $link);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Link revoked.']);

        return back();
    }
}
