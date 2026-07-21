<?php

use App\Actions\Rfid\IngestRfidScan;
use App\Actions\RfidCards\AssignRfidCard;
use App\Enums\RfidCardStatus;
use App\Enums\RfidScanClassification;
use App\Models\AttendanceRule;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\Student;
use Illuminate\Support\Carbon;

test('a scan for an actively assigned card is classified valid', function () {
    $device = RfidDevice::factory()->create();
    $student = Student::factory()->create();
    app(AssignRfidCard::class)($student, 'ABCD1234');

    $scan = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');

    expect($scan->classification)->toBe(RfidScanClassification::Valid);
});

test('a scan for a uid never assigned to any card is classified unknown_card', function () {
    $device = RfidDevice::factory()->create();

    $scan = (new IngestRfidScan)($device, 'NEVER-SEEN', Carbon::now(), 'req-1');

    expect($scan->classification)->toBe(RfidScanClassification::UnknownCard);
});

test('a scan for a uid whose only card rows are inactive is classified inactive_card', function () {
    $device = RfidDevice::factory()->create();
    $student = Student::factory()->create();
    $card = app(AssignRfidCard::class)($student, 'ABCD1234');
    $card->update(['status' => RfidCardStatus::Deactivated]);

    $scan = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');

    expect($scan->classification)->toBe(RfidScanClassification::InactiveCard);
});

test('a second scan of the same uid within the duplicate window is classified duplicate_window', function () {
    $device = RfidDevice::factory()->create();

    $first = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');
    $second = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-2');

    expect($first->classification)->toBe(RfidScanClassification::UnknownCard);
    expect($second->classification)->toBe(RfidScanClassification::DuplicateWindow);
    expect(RfidScan::query()->count())->toBe(2);
});

test('a second scan of the same uid outside the duplicate window is classified independently', function () {
    $device = RfidDevice::factory()->create();

    (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');

    $this->travel(6)->seconds();

    $second = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-2');

    expect($second->classification)->toBe(RfidScanClassification::UnknownCard);
});

test('replaying the same device and request_id returns the existing row without creating a new one', function () {
    $device = RfidDevice::factory()->create();

    $first = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');
    $replay = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');

    expect($replay->id)->toBe($first->id);
    expect(RfidScan::query()->count())->toBe(1);
});

test('the duplicate window uses the configured AttendanceRule value, not the hardcoded default', function () {
    AttendanceRule::factory()->create(['duplicate_window_seconds' => 2]);
    $device = RfidDevice::factory()->create();

    (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-1');

    $this->travel(3)->seconds();

    $second = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-2');

    // 3 seconds have passed, beyond the configured 2-second window, even
    // though it is within the action's old hardcoded 5-second default.
    expect($second->classification)->toBe(RfidScanClassification::UnknownCard);
});

test('the same request_id from a different device is not treated as a replay', function () {
    $deviceA = RfidDevice::factory()->create();
    $deviceB = RfidDevice::factory()->create();

    $first = (new IngestRfidScan)($deviceA, 'ABCD1234', Carbon::now(), 'req-1');
    $second = (new IngestRfidScan)($deviceB, 'ABCD1234', Carbon::now(), 'req-1');

    expect($second->id)->not->toBe($first->id);
    expect(RfidScan::query()->count())->toBe(2);
});
