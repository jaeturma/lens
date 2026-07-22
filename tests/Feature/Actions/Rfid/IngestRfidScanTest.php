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
use Illuminate\Support\Facades\DB;

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

test('a concurrent request committing the same device+request_id between this '
    .'request\'s replay check and its own insert is handled without erroring or '
    .'duplicating (WP-08-04)', function () {
        $device = RfidDevice::factory()->create();

        // Reproduces exactly the race the replay check alone cannot close: a
        // single test process can't run two real concurrent requests, so a
        // one-off `creating` listener inserts the "other request"'s row via a
        // raw statement (bypassing Eloquent, so it can't recurse into this
        // same listener) at the precise moment this action's own insert is
        // about to happen — after its replay check already ran and found
        // nothing.
        RfidScan::creating(function () use ($device) {
            DB::table('rfid_scans')->insert([
                'rfid_device_id' => $device->id,
                'uid' => 'ABCD1234',
                'device_timestamp' => now(),
                'request_id' => 'req-race',
                'classification' => RfidScanClassification::UnknownCard->value,
                'created_at' => now(),
            ]);
        });

        $scan = (new IngestRfidScan)($device, 'ABCD1234', Carbon::now(), 'req-race');

        expect($scan->request_id)->toBe('req-race');
        expect(
            RfidScan::query()
                ->where('rfid_device_id', $device->id)
                ->where('request_id', 'req-race')
                ->count()
        )->toBe(1);
    });

test('the same request_id from a different device is not treated as a replay', function () {
    $deviceA = RfidDevice::factory()->create();
    $deviceB = RfidDevice::factory()->create();

    $first = (new IngestRfidScan)($deviceA, 'ABCD1234', Carbon::now(), 'req-1');
    $second = (new IngestRfidScan)($deviceB, 'ABCD1234', Carbon::now(), 'req-1');

    expect($second->id)->not->toBe($first->id);
    expect(RfidScan::query()->count())->toBe(2);
});
