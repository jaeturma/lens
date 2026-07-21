<?php

namespace App\Http\Controllers\Api\V1\Rfid;

use App\Actions\Rfid\IngestRfidScan;
use App\Http\Controllers\Controller;
use App\Http\Requests\Rfid\StoreRfidScanRequest;
use App\Http\Responses\ApiResponse;
use App\Models\RfidDevice;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Carbon;

class IngestRfidScanController extends Controller
{
    public function __invoke(StoreRfidScanRequest $request, IngestRfidScan $ingestRfidScan): JsonResponse
    {
        /** @var RfidDevice $device */
        $device = $request->attributes->get('rfidDevice');

        $scan = $ingestRfidScan(
            $device,
            $request->validated('uid'),
            Carbon::parse($request->validated('device_timestamp')),
            $request->validated('request_id'),
        );

        return ApiResponse::success(['id' => $scan->id], 'Scan recorded.');
    }
}
