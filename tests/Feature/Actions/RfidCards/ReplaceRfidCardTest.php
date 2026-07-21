<?php

use App\Actions\RfidCards\ReplaceRfidCard;
use App\Enums\RfidCardStatus;
use App\Exceptions\RfidCards\RfidUidAlreadyActiveException;
use App\Models\RfidCard;
use App\Models\User;

test('it replaces a card: the old row becomes Replaced and a new active row is created', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $oldCard = RfidCard::factory()->create(['uid' => 'OLD1234', 'status' => RfidCardStatus::Active]);

    $newCard = app(ReplaceRfidCard::class)($oldCard, 'NEW5678', $actor);

    expect($newCard->id)->not->toBe($oldCard->id)
        ->and($newCard->uid)->toBe('NEW5678')
        ->and($newCard->status)->toBe(RfidCardStatus::Active)
        ->and($newCard->student_id)->toBe($oldCard->student_id);

    expect($oldCard->fresh()->status)->toBe(RfidCardStatus::Replaced);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $actor->id,
        'action' => 'rfid_card.replaced',
        'target_type' => 'rfid_card',
        'target_id' => $newCard->id,
    ]);
});

test('it rejects replacing with a uid that is already actively assigned elsewhere, leaving the old card unchanged', function () {
    $oldCard = RfidCard::factory()->create(['uid' => 'OLD1234', 'status' => RfidCardStatus::Active]);
    RfidCard::factory()->create(['uid' => 'TAKEN99', 'status' => RfidCardStatus::Active]);

    expect(fn () => app(ReplaceRfidCard::class)($oldCard, 'TAKEN99'))
        ->toThrow(RfidUidAlreadyActiveException::class);

    expect($oldCard->fresh()->status)->toBe(RfidCardStatus::Active);
});
