<?php

namespace App\Http\Controllers\RfidCards;

use App\Actions\RfidCards\ReplaceRfidCard;
use App\Exceptions\RfidCards\RfidUidAlreadyActiveException;
use App\Http\Controllers\Controller;
use App\Http\Requests\RfidCards\ReplaceRfidCardRequest;
use App\Models\RfidCard;
use Illuminate\Http\RedirectResponse;
use Illuminate\Validation\ValidationException;
use Inertia\Inertia;

class ReplaceRfidCardController extends Controller
{
    public function __invoke(ReplaceRfidCardRequest $request, RfidCard $card, ReplaceRfidCard $replaceRfidCard): RedirectResponse
    {
        try {
            $replaceRfidCard($card, $request->validated('uid'), $request->user());
        } catch (RfidUidAlreadyActiveException $exception) {
            throw ValidationException::withMessages(['uid' => $exception->getMessage()]);
        }

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Card replaced.']);

        return to_route('rfid-cards.index');
    }
}
