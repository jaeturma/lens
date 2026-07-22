<?php

namespace App\Http\Controllers\Announcements;

use App\Actions\Announcements\WithdrawAnnouncement;
use App\Actions\Audit\RecordAuditLog;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Http\Controllers\Controller;
use App\Models\Announcement;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;

class WithdrawAnnouncementController extends Controller
{
    public function __invoke(Request $request, Announcement $announcement, WithdrawAnnouncement $withdrawAnnouncement, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $this->authorize('update', $announcement);

        try {
            $withdrawAnnouncement($announcement);
        } catch (InvalidAnnouncementTransitionException $exception) {
            throw ValidationException::withMessages(['status' => $exception->getMessage()]);
        }

        $recordAuditLog($request->user(), 'announcement.withdrawn', $announcement, [
            'title' => $announcement->title,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Announcement withdrawn.']);

        return back();
    }
}
