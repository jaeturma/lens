<?php

namespace App\Actions\RfidCards;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\RfidCardStatus;
use App\Exceptions\RfidCards\RfidUidAlreadyActiveException;
use App\Models\RfidCard;
use App\Models\User;
use Illuminate\Database\QueryException;
use Illuminate\Support\Facades\DB;

class ReplaceRfidCard
{
    public function __construct(private readonly RecordAuditLog $recordAuditLog) {}

    public function __invoke(RfidCard $currentCard, string $newUid, ?User $actor = null): RfidCard
    {
        if (RfidCard::query()->where('active_uid', $newUid)->exists()) {
            throw new RfidUidAlreadyActiveException($newUid);
        }

        $newCard = DB::transaction(function () use ($currentCard, $newUid) {
            $currentCard->update(['status' => RfidCardStatus::Replaced]);

            try {
                return RfidCard::create([
                    'uid' => $newUid,
                    'student_id' => $currentCard->student_id,
                    'status' => RfidCardStatus::Active,
                ]);
            } catch (QueryException $exception) {
                throw new RfidUidAlreadyActiveException($newUid, previous: $exception);
            }
        });

        ($this->recordAuditLog)($actor, 'rfid_card.replaced', $newCard, [
            'uid' => $newCard->uid,
            'student_id' => $newCard->student_id,
            'previous_card_id' => $currentCard->id,
            'previous_uid' => $currentCard->uid,
        ]);

        return $newCard;
    }
}
