<?php

use App\Actions\RfidCards\DeactivateRfidCard;
use App\Enums\RfidCardStatus;
use App\Models\RfidCard;
use App\Models\User;

test('it deactivates a card and records an audit log entry', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $card = RfidCard::factory()->create(['status' => RfidCardStatus::Active]);

    $updated = app(DeactivateRfidCard::class)($card, $actor);

    expect($updated->status)->toBe(RfidCardStatus::Deactivated);
    expect($card->fresh()->status)->toBe(RfidCardStatus::Deactivated);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $actor->id,
        'action' => 'rfid_card.deactivated',
        'target_type' => 'rfid_card',
        'target_id' => $card->id,
    ]);
});

test('deactivating frees the uid for a new active assignment', function () {
    $card = RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);

    app(DeactivateRfidCard::class)($card);

    $reassigned = RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);

    expect($reassigned->uid)->toBe('ABCD1234');
});
