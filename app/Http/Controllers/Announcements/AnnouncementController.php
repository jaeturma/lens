<?php

namespace App\Http\Controllers\Announcements;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\StudentStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Announcements\IndexAnnouncementsRequest;
use App\Http\Requests\Announcements\StoreAnnouncementRequest;
use App\Http\Requests\Announcements\UpdateAnnouncementRequest;
use App\Models\Announcement;
use App\Models\Student;
use Illuminate\Database\Eloquent\Collection;
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

        return Inertia::render('announcements/create', [
            'assignableStudents' => $this->assignableStudents(),
        ]);
    }

    public function store(StoreAnnouncementRequest $request, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $validated = $request->validated();
        $studentIds = $validated['student_ids'] ?? [];
        unset($validated['student_ids']);

        $announcement = Announcement::create([
            ...$validated,
            'author_id' => $request->user()->id,
        ]);

        $announcement->students()->sync($studentIds);

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
            'announcement' => $announcement->load('students:id,name,lrn'),
        ]);
    }

    public function edit(Announcement $announcement): Response
    {
        $this->authorize('update', $announcement);

        return Inertia::render('announcements/edit', [
            'announcement' => $announcement->load('students:id'),
            'assignableStudents' => $this->assignableStudents(),
        ]);
    }

    public function update(UpdateAnnouncementRequest $request, Announcement $announcement, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $validated = $request->validated();
        $studentIds = $validated['student_ids'] ?? [];
        unset($validated['student_ids']);

        $announcement->update($validated);
        $announcement->students()->sync($studentIds);

        $recordAuditLog($request->user(), 'announcement.updated', $announcement, [
            'title' => $announcement->title,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Announcement updated.']);

        return to_route('announcements.show', $announcement);
    }

    /**
     * @return Collection<int, Student>
     */
    private function assignableStudents(): Collection
    {
        return Student::query()
            ->where('status', StudentStatus::Active)
            ->orderBy('name')
            ->get(['id', 'name', 'lrn']);
    }
}
