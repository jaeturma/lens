<?php

namespace App\Actions\RfidCards;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\RfidCardStatus;
use App\Models\RfidCard;
use App\Models\User;

class DeactivateRfidCard
{
    public function __construct(private readonly RecordAuditLog $recordAuditLog) {}

    public function __invoke(RfidCard $card, ?User $actor = null): RfidCard
    {
        $card->update(['status' => RfidCardStatus::Deactivated]);

        ($this->recordAuditLog)($actor, 'rfid_card.deactivated', $card, [
            'uid' => $card->uid,
            'student_id' => $card->student_id,
        ]);

        return $card;
    }
}
