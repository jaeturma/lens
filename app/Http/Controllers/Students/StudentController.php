<?php

namespace App\Http\Controllers\Students;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\StudentStatus;
use App\Http\Controllers\Controller;
use App\Http\Requests\Students\IndexStudentsRequest;
use App\Http\Requests\Students\StoreStudentRequest;
use App\Http\Requests\Students\UpdateStudentRequest;
use App\Models\Student;
use Illuminate\Http\RedirectResponse;
use Inertia\Inertia;
use Inertia\Response;

class StudentController extends Controller
{
    public function index(IndexStudentsRequest $request): Response
    {
        $filters = $request->filters();

        $students = Student::query()
            ->when($filters['q'] ?? null, function ($query, string $q) {
                $query->where(function ($query) use ($q) {
                    $query->where('name', 'like', "%{$q}%")
                        ->orWhere('lrn', 'like', "%{$q}%")
                        ->orWhere('student_number', 'like', "%{$q}%");
                });
            })
            ->when($filters['grade'] ?? null, fn ($query, string $grade) => $query->where('grade', $grade))
            ->when($filters['section'] ?? null, fn ($query, string $section) => $query->where('section', $section))
            ->when($filters['school_year'] ?? null, fn ($query, string $schoolYear) => $query->where('school_year', $schoolYear))
            ->when($filters['status'] ?? null, fn ($query, string $status) => $query->where('status', $status))
            ->orderBy('name')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('students/index', [
            'students' => $students,
            'filters' => $filters,
        ]);
    }

    public function create(): Response
    {
        $this->authorize('create', Student::class);

        return Inertia::render('students/create');
    }

    public function store(StoreStudentRequest $request, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $student = Student::create([
            ...$request->validated(),
            'status' => StudentStatus::Active,
        ]);

        $recordAuditLog($request->user(), 'student.created', $student, [
            'lrn' => $student->lrn,
            'name' => $student->name,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Student created.']);

        return to_route('students.show', $student);
    }

    public function show(Student $student): Response
    {
        $this->authorize('view', $student);

        return Inertia::render('students/show', [
            'student' => $student,
        ]);
    }

    public function edit(Student $student): Response
    {
        $this->authorize('update', $student);

        return Inertia::render('students/edit', [
            'student' => $student,
        ]);
    }

    public function update(UpdateStudentRequest $request, Student $student, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $student->update($request->validated());

        $recordAuditLog($request->user(), 'student.updated', $student, [
            'lrn' => $student->lrn,
            'name' => $student->name,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Student updated.']);

        return to_route('students.show', $student);
    }
}
