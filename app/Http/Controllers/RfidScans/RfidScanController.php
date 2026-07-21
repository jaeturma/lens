<?php

namespace App\Http\Controllers\RfidScans;

use App\Http\Controllers\Controller;
use App\Http\Requests\RfidScans\IndexRfidScansRequest;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use Inertia\Inertia;
use Inertia\Response;

class RfidScanController extends Controller
{
    public function index(IndexRfidScansRequest $request): Response
    {
        $filters = $request->filters();

        $scans = RfidScan::query()
            ->with('device')
            ->when($filters['rfid_device_id'] ?? null, fn ($query, $deviceId) => $query->where('rfid_device_id', $deviceId))
            ->when($filters['classification'] ?? null, fn ($query, string $classification) => $query->where('classification', $classification))
            ->orderByDesc('created_at')
            ->paginate(25)
            ->withQueryString();

        return Inertia::render('rfid/scans/index', [
            'scans' => $scans,
            'filters' => $filters,
            'devices' => RfidDevice::query()->orderBy('device_code')->get(['id', 'device_code', 'location']),
        ]);
    }
}
