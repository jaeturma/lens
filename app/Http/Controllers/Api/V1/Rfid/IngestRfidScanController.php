<?php

namespace App\Http\Controllers\Api\V1\Rfid;

use App\Http\Controllers\Controller;
use App\Http\Requests\Rfid\StoreRfidScanRequest;
use App\Http\Responses\ApiResponse;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use Illuminate\Http\JsonResponse;

class IngestRfidScanController extends Controller
{
    public function __invoke(StoreRfidScanRequest $request): JsonResponse
    {
        /** @var RfidDevice $device */
        $device = $request->attributes->get('rfidDevice');

        $scan = RfidScan::create([
            'rfid_device_id' => $device->id,
            ...$request->validated(),
        ]);

        return ApiResponse::success(['id' => $scan->id], 'Scan recorded.');
    }
}
