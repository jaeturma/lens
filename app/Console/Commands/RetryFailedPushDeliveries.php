<?php

namespace App\Console\Commands;

use App\Actions\Notifications\RetryFailedPushSignals;
use Illuminate\Console\Command;

class RetryFailedPushDeliveries extends Command
{
    protected $signature = 'notifications:retry-failed-push';

    protected $description = 'Re-attempt push delivery for notifications that previously failed, up to a maximum number of attempts';

    public function handle(RetryFailedPushSignals $retryFailedPushSignals): int
    {
        $retried = $retryFailedPushSignals();

        $this->info("Re-dispatched {$retried} notification(s) for retry.");

        return self::SUCCESS;
    }
}
