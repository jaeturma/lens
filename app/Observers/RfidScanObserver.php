<?php

namespace App\Observers;

use App\Actions\Attendance\ProcessRfidScan;
use App\Models\RfidScan;

class RfidScanObserver
{
    public function __construct(private readonly ProcessRfidScan $processRfidScan) {}

    public function created(RfidScan $scan): void
    {
        ($this->processRfidScan)($scan);
    }
}
