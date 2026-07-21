<?php

use App\Enums\RfidCardStatus;
use App\Models\RfidCard;
use Illuminate\Database\QueryException;

test('two active rows cannot share the same uid', function () {
    $existing = RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);

    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);
})->throws(QueryException::class);

test('a deactivated row does not block reusing its uid on an active row', function () {
    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Deactivated]);

    $newCard = RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);

    expect($newCard->uid)->toBe('ABCD1234');
});

test('multiple non-active rows can share the same uid', function () {
    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Deactivated]);
    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Replaced]);

    expect(RfidCard::query()->where('uid', 'ABCD1234')->count())->toBe(2);
});

test('status is cast to its enum', function () {
    $card = RfidCard::factory()->create(['status' => RfidCardStatus::Replaced]);

    expect($card->fresh()->status)->toBe(RfidCardStatus::Replaced);
});
