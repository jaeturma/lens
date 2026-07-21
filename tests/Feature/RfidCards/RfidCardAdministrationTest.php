<?php

use App\Enums\RfidCardStatus;
use App\Models\RfidCard;
use App\Models\Student;
use App\Models\User;

test('a guardian is rejected from every rfid-cards route', function () {
    $guardian = User::factory()->create();
    $card = RfidCard::factory()->create(['status' => RfidCardStatus::Active]);

    $this->actingAs($guardian)->get(route('rfid-cards.index'))->assertForbidden();
    $this->actingAs($guardian)->get(route('rfid-cards.create'))->assertForbidden();
    $this->actingAs($guardian)->post(route('rfid-cards.store'), [])->assertForbidden();
    $this->actingAs($guardian)->patch(route('rfid-cards.deactivate', $card))->assertForbidden();
    $this->actingAs($guardian)->patch(route('rfid-cards.replace', $card), [])->assertForbidden();
});

test('an administrator can view, search, and filter the cards index', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create(['name' => 'Juan Dela Cruz']);
    RfidCard::factory()->for($student)->create(['uid' => 'AAAA1111', 'status' => RfidCardStatus::Active]);
    RfidCard::factory()->create(['status' => RfidCardStatus::Deactivated]);

    $this->actingAs($admin)->get(route('rfid-cards.index'))->assertOk();

    $response = $this->actingAs($admin)->get(route('rfid-cards.index', ['q' => 'Dela Cruz', 'status' => 'active']));

    $response->assertInertia(fn ($page) => $page->has('cards.data', 1));
});

test('an administrator can assign a card to a student', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();

    $response = $this->actingAs($admin)->post(route('rfid-cards.store'), [
        'student_id' => $student->id,
        'uid' => 'ABCD1234',
    ]);

    $response->assertRedirect(route('rfid-cards.index'));
    $card = RfidCard::query()->where('uid', 'ABCD1234')->firstOrFail();
    expect($card->student_id)->toBe($student->id);
    expect($card->status)->toBe(RfidCardStatus::Active);

    $this->assertDatabaseHas('audit_logs', [
        'actor_id' => $admin->id,
        'action' => 'rfid_card.assigned',
        'target_id' => $card->id,
    ]);
});

test('assigning a uid already actively assigned is rejected with a validation error', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $student = Student::factory()->create();
    RfidCard::factory()->create(['uid' => 'ABCD1234', 'status' => RfidCardStatus::Active]);

    $response = $this->actingAs($admin)->post(route('rfid-cards.store'), [
        'student_id' => $student->id,
        'uid' => 'ABCD1234',
    ]);

    $response->assertSessionHasErrors('uid');
    expect(RfidCard::query()->where('uid', 'ABCD1234')->count())->toBe(1);
});

test('an administrator can deactivate a card', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $card = RfidCard::factory()->create(['status' => RfidCardStatus::Active]);

    $response = $this->actingAs($admin)->patch(route('rfid-cards.deactivate', $card));

    $response->assertRedirect();
    expect($card->fresh()->status)->toBe(RfidCardStatus::Deactivated);
});

test('an administrator can replace a card', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $oldCard = RfidCard::factory()->create(['uid' => 'OLD1234', 'status' => RfidCardStatus::Active]);

    $response = $this->actingAs($admin)->patch(route('rfid-cards.replace', $oldCard), [
        'uid' => 'NEW5678',
    ]);

    $response->assertRedirect(route('rfid-cards.index'));
    expect($oldCard->fresh()->status)->toBe(RfidCardStatus::Replaced);
    expect(RfidCard::query()->where('uid', 'NEW5678')->where('status', RfidCardStatus::Active)->exists())->toBeTrue();
});

test('replacing with a uid already actively assigned elsewhere is rejected', function () {
    $admin = User::factory()->schoolAdministrator()->create();
    $oldCard = RfidCard::factory()->create(['uid' => 'OLD1234', 'status' => RfidCardStatus::Active]);
    RfidCard::factory()->create(['uid' => 'TAKEN99', 'status' => RfidCardStatus::Active]);

    $response = $this->actingAs($admin)->patch(route('rfid-cards.replace', $oldCard), [
        'uid' => 'TAKEN99',
    ]);

    $response->assertSessionHasErrors('uid');
    expect($oldCard->fresh()->status)->toBe(RfidCardStatus::Active);
});
