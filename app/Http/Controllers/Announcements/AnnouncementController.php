<?php

namespace App\Http\Controllers\Announcements;

use App\Actions\Audit\RecordAuditLog;
use App\Http\Controllers\Controller;
use App\Http\Requests\Announcements\IndexAnnouncementsRequest;
use App\Http\Requests\Announcements\StoreAnnouncementRequest;
use App\Http\Requests\Announcements\UpdateAnnouncementRequest;
use App\Models\Announcement;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class AnnouncementController extends Controller
{
    public function index(IndexAnnouncementsRequest $request): Response
    {
        $filters = $request->filters();

        $announcements = Announcement::query()
            ->when($filters['q'] ?? null, fn ($query, string $q) => $query->where('title', 'like', "%{$q}%"))
            ->when($filters['status'] ?? null, fn ($query, string $status) => $query->where('status', $status))
            ->orderByDesc('created_at')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('announcements/index', [
            'announcements' => $announcements,
            'filters' => $filters,
        ]);
    }

    public function create(): Response
    {
        $this->authorize('create', Announcement::class);

        return Inertia::render('announcements/create');
    }

    public function store(StoreAnnouncementRequest $request, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $announcement = Announcement::create([
            ...$request->validated(),
            'author_id' => $request->user()->id,
        ]);

        $recordAuditLog($request->user(), 'announcement.created', $announcement, [
            'title' => $announcement->title,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Announcement created.']);

        return to_route('announcements.show', $announcement);
    }

    public function show(Announcement $announcement): Response
    {
        $this->authorize('view', $announcement);

        return Inertia::render('announcements/show', [
            'announcement' => $announcement,
        ]);
    }

    public function edit(Announcement $announcement): Response
    {
        $this->authorize('update', $announcement);

        return Inertia::render('announcements/edit', [
            'announcement' => $announcement,
        ]);
    }

    public function update(UpdateAnnouncementRequest $request, Announcement $announcement, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $announcement->update($request->validated());

        $recordAuditLog($request->user(), 'announcement.updated', $announcement, [
            'title' => $announcement->title,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Announcement updated.']);

        return to_route('announcements.show', $announcement);
    }
}
