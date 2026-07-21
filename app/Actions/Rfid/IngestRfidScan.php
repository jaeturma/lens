<?php

namespace App\Actions\Rfid;

use App\Enums\RfidScanClassification;
use App\Models\RfidCard;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use Illuminate\Support\Carbon;

class IngestRfidScan
{
    private const DUPLICATE_WINDOW_SECONDS = 5;

    public function __invoke(RfidDevice $device, string $uid, Carbon $deviceTimestamp, string $requestId): RfidScan
    {
        $existing = RfidScan::query()
            ->where('rfid_device_id', $device->id)
            ->where('request_id', $requestId)
            ->first();

        if ($existing) {
            return $existing;
        }

        return RfidScan::create([
            'rfid_device_id' => $device->id,
            'uid' => $uid,
            'device_timestamp' => $deviceTimestamp,
            'request_id' => $requestId,
            'classification' => $this->classify($uid),
        ]);
    }

    private function classify(string $uid): RfidScanClassification
    {
        $withinDuplicateWindow = RfidScan::query()
            ->where('uid', $uid)
            ->where('created_at', '>=', now()->subSeconds(self::DUPLICATE_WINDOW_SECONDS))
            ->exists();

        if ($withinDuplicateWindow) {
            return RfidScanClassification::DuplicateWindow;
        }

        $hasActiveCard = RfidCard::query()->where('active_uid', $uid)->exists();

        if ($hasActiveCard) {
            return RfidScanClassification::Valid;
        }

        $everAssigned = RfidCard::query()->where('uid', $uid)->exists();

        return $everAssigned ? RfidScanClassification::InactiveCard : RfidScanClassification::UnknownCard;
    }
}
