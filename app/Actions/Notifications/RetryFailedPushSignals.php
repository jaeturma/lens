<?php

namespace App\Actions\Notifications;

use App\Enums\NotificationDeliveryStatus;
use App\Jobs\SendPushSignal;
use App\Models\GuardianNotification;

class RetryFailedPushSignals
{
    /**
     * "Retry state": every Failed notification with fewer than
     * MAX_ATTEMPTS logged App\Models\PushDeliveryAttempt rows gets
     * re-dispatched. A notification that has exhausted MAX_ATTEMPTS is
     * left Failed permanently — this sweep simply stops reconsidering it,
     * no separate "gave up" state is needed.
     */
    private const MAX_ATTEMPTS = 3;

    /**
     * @return int number of notifications re-dispatched
     */
    public function __invoke(): int
    {
        $candidates = GuardianNotification::query()
            ->where('delivery_status', NotificationDeliveryStatus::Failed)
            ->has('pushDeliveryAttempts', '<', self::MAX_ATTEMPTS)
            ->get();

        foreach ($candidates as $notification) {
            SendPushSignal::dispatch($notification);
        }

        return $candidates->count();
    }
}
