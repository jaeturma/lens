<?php

namespace App\Http\Controllers\RfidCards;

use App\Actions\RfidCards\AssignRfidCard;
use App\Exceptions\RfidCards\RfidUidAlreadyActiveException;
use App\Http\Controllers\Controller;
use App\Http\Requests\RfidCards\IndexRfidCardsRequest;
use App\Http\Requests\RfidCards\StoreRfidCardRequest;
use App\Models\RfidCard;
use App\Models\Student;
use Illuminate\Http\RedirectResponse;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;
use Inertia\Response;

class RfidCardController extends Controller
{
    public function index(IndexRfidCardsRequest $request): Response
    {
        $filters = $request->filters();

        $cards = RfidCard::query()
            ->with('student')
            ->when($filters['q'] ?? null, function ($query, string $q) {
                $query->where(function ($query) use ($q) {
                    $query->where('uid', 'like', "%{$q}%")
                        ->orWhereHas('student', function ($query) use ($q) {
                            $query->where('name', 'like', "%{$q}%");
                        });
                });
            })
            ->when($filters['status'] ?? null, fn ($query, string $status) => $query->where('status', $status))
            ->orderByDesc('created_at')
            ->paginate(15)
            ->withQueryString();

        return Inertia::render('rfid/cards/index', [
            'cards' => $cards,
            'filters' => $filters,
        ]);
    }

    public function create(): Response
    {
        $this->authorize('create', RfidCard::class);

        return Inertia::render('rfid/cards/create', [
            'assignableStudents' => Student::query()->orderBy('name')->get(['id', 'name', 'lrn']),
        ]);
    }

    public function store(StoreRfidCardRequest $request, AssignRfidCard $assignRfidCard): RedirectResponse
    {
        $validated = $request->validated();
        $student = Student::query()->where('id', $validated['student_id'])->firstOrFail();

        try {
            $assignRfidCard($student, $validated['uid'], $request->user());
        } catch (RfidUidAlreadyActiveException $exception) {
            throw ValidationException::withMessages(['uid' => $exception->getMessage()]);
        }

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Card assigned.']);

        return to_route('rfid-cards.index');
    }
}
