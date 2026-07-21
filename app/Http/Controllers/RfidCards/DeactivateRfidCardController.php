<?php

namespace App\Http\Controllers\RfidCards;

use App\Actions\RfidCards\DeactivateRfidCard;
use App\Http\Controllers\Controller;
use App\Models\RfidCard;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Inertia\Inertia;

class DeactivateRfidCardController extends Controller
{
    public function __invoke(Request $request, RfidCard $card, DeactivateRfidCard $deactivateRfidCard): RedirectResponse
    {
        $this->authorize('update', $card);

        $deactivateRfidCard($card, $request->user());

        Inertia::flash('toast', ['type' => 'success', 'message' => 'Card deactivated.']);

        return back();
    }
}
