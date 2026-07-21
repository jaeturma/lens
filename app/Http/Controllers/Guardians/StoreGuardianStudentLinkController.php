<?php

namespace App\Http\Controllers\Guardians;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\GuardianStudentLinkStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Guardians\StoreGuardianStudentLinkRequest;
use App\Models\Guardian;
use App\Models\GuardianStudentLink;
use Illuminate\Http\RedirectResponse;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;

class StoreGuardianStudentLinkController extends Controller
{
    public function __invoke(StoreGuardianStudentLinkRequest $request, Guardian $guardian, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $validated = $request->validated();

        $link = GuardianStudentLink::query()
            ->where('guardian_id', $guardian->id)
            ->where('student_id', $validated['student_id'])
            ->first();

        if ($link && $link->status === GuardianStudentLinkStatus::Active) {
            throw ValidationException::withMessages([
                'student_id' => 'This student is already linked to this guardian.',
            ]);
        }

        $attributes = [
            'relationship_type' => $validated['relationship_type'],
            'is_primary_contact' => $request->boolean('is_primary_contact'),
            'status' => GuardianStudentLinkStatus::Active,
            'notifications_enabled' => $request->boolean('notifications_enabled', true),
        ];

        if ($link) {
            $link->update($attributes);
        } else {
            $link = GuardianStudentLink::create([
                'student_id' => $validated['student_id'],
                'guardian_id' => $guardian->id,
                ...$attributes,
            ]);
        }

        $recordAuditLog($request->user(), 'guardian_student_link.created', $link, [
            'student_id' => $link->student_id,
            'guardian_id' => $link->guardian_id,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Student linked.']);

        return back();
    }
}
