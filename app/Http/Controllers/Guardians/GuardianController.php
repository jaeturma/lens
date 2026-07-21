<?php

namespace App\Http\Controllers\Guardians;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\GuardianStatus;
use App\Enums\UserRole;
use App\Http\Controllers\Controller;
use App\Http\Requests\Guardians\IndexGuardiansRequest;
use App\Http\Requests\Guardians\StoreGuardianRequest;
use App\Http\Requests\Guardians\UpdateGuardianRequest;
use App\Models\Guardian;
use App\Models\Student;
use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\Rules\Password;
use Inertia\Inertia;
use Inertia\Response;

class GuardianController extends Controller
{
    public function index(IndexGuardiansRequest $request): Response
    {
        $filters = $request->filters();

        $guardians = Guardian::query()
            ->when($filters['q'] ?? null, function ($query, string $q) {
                $query->where(function ($query) use ($q) {
                    $query->where('name', 'like', "%{$q}%")
                        ->orWhere('email', 'like', "%{$q}%")
                        ->orWhere('mobile_number', 'like', "%{$q}%");
                });
            })
            ->when($filters['status'] ?? null, fn ($query, string $status) => $query->where('status', $status))
            ->orderBy('name')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('guardians/index', [
            'guardians' => $guardians,
            'filters' => $filters,
        ]);
    }

    public function create(): Response
    {
        $this->authorize('create', Guardian::class);

        return Inertia::render('guardians/create', [
            'passwordRules' => Password::defaults()->toPasswordRulesString(),
        ]);
    }

    public function store(StoreGuardianRequest $request, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $validated = $request->validated();

        $guardian = DB::transaction(function () use ($validated) {
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => $validated['password'],
                'role' => UserRole::Guardian,
            ]);

            return Guardian::create([
                'user_id' => $user->id,
                'name' => $validated['name'],
                'email' => $validated['email'],
                'mobile_number' => $validated['mobile_number'],
                'status' => GuardianStatus::Active,
                'notify_attendance' => true,
                'notify_announcements' => true,
            ]);
        });

        $recordAuditLog($request->user(), 'guardian.created', $guardian, [
            'name' => $guardian->name,
            'email' => $guardian->email,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Guardian created.']);

        return to_route('guardians.show', $guardian);
    }

    public function show(Guardian $guardian): Response
    {
        $this->authorize('view', $guardian);

        $links = $guardian->links()->with('student')->orderBy('created_at')->get();
        $linkableStudents = Student::query()->orderBy('name')->get(['id', 'name', 'lrn']);

        return Inertia::render('guardians/show', [
            'guardian' => $guardian,
            'links' => $links,
            'linkableStudents' => $linkableStudents,
        ]);
    }

    public function edit(Guardian $guardian): Response
    {
        $this->authorize('update', $guardian);

        return Inertia::render('guardians/edit', [
            'guardian' => $guardian,
        ]);
    }

    public function update(UpdateGuardianRequest $request, Guardian $guardian, RecordAuditLog $recordAuditLog): RedirectResponse
    {
        $guardian->update([
            'name' => $request->validated('name'),
            'email' => $request->validated('email'),
            'mobile_number' => $request->validated('mobile_number'),
            'notify_attendance' => $request->boolean('notify_attendance'),
            'notify_announcements' => $request->boolean('notify_announcements'),
        ]);

        $recordAuditLog($request->user(), 'guardian.updated', $guardian, [
            'name' => $guardian->name,
            'email' => $guardian->email,
        ]);

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Guardian updated.']);

        return to_route('guardians.show', $guardian);
    }
}
