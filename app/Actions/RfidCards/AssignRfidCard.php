<?php

namespace App\Actions\RfidCards;

use App\Actions\Audit\RecordAuditLog;
use App\Enums\RfidCardStatus;
use App\Exceptions\RfidCards\RfidUidAlreadyActiveException;
use App\Models\RfidCard;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\QueryException;

class AssignRfidCard
{
    public function __construct(private readonly RecordAuditLog $recordAuditLog) {}

    public function __invoke(Student $student, string $uid, ?User $actor = null): RfidCard
    {
        if (RfidCard::query()->where('active_uid', $uid)->exists()) {
            throw new RfidUidAlreadyActiveException($uid);
        }

        try {
            $card = RfidCard::create([
                'uid' => $uid,
                'student_id' => $student->id,
                'status' => RfidCardStatus::Active,
            ]);
        } catch (QueryException $exception) {
            throw new RfidUidAlreadyActiveException($uid, previous: $exception);
        }

        ($this->recordAuditLog)($actor, 'rfid_card.assigned', $card, [
            'uid' => $card->uid,
            'student_id' => $student->id,
        ]);

        return $card;
    }
}
