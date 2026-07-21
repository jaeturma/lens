<?php

use App\Actions\RfidCards\AssignRfidCard;
use App\Enums\RfidCardStatus;
use App\Exceptions\RfidCards\RfidUidAlreadyActiveException;
use App\Models\RfidCard;
use App\Models\Student;
use App\Models\User;

test('it assigns a new active card and records an audit log entry', function () {
    $actor = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();

    $card = app(AssignRfidCard::class)($student, 'ABCD1234', $actor);

    expect($card->uid)->toBe('ABCD1234')
        ->and($card->student_id)->toBe($student->id)
        ->and($card->status)->toBe(RfidCardStatus::Active);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $actor->id,
        'action' => 'rfid_card.assigned',
        'target_type' => 'rfid_card',
        'target_id' => $card->id,
    ]);
});

test('it rejects assigning a uid that is already actively assigned', function () {
    $student = Student::factory()->create();
    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);

    app(AssignRfidCard::class)($student, 'ABCD1234');
})->throws(RfidUidAlreadyActiveException::class);

test('it allows assigning a uid that was previously deactivated', function () {
    $student = Student::factory()->create();
    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Deactivated]);

    $card = app(AssignRfidCard::class)($student, 'ABCD1234');

    expect($card->status)->toBe(RfidCardStatus::Active);
});
