<?php

namespace App\Http\Controllers\Guardians;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\GuardianStatus;
use App\Http\Controllers\Controller;
use App\Models\Guardian;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;

class ActivateGuardianController extends Controller
{
    public function __invoke(Request $request, Guardian $guardian, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $this->authorize('update', $guardian);

        $guardian->update(['status' => GuardianStatus::Active]);

        $recordAuditLog($request->user(), 'guardian.activated', $guardian);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Guardian activated.']);

        return back();
    }
}
