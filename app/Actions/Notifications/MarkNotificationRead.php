<?php

namespace App\Actions\Notifications;

use App\Models\GuardianNotification;

class MarkNotificationRead
{
    /**
     * Idempotent — an already-read notification is left untouched rather
     * than bumping read_at/updated_at again, avoiding a no-op sync_changes
     * "updated" entry (App\Observers\GuardianNotificationObserver) for
     * every repeat call.
     */
    public function __invoke(GuardianNotification $notification): GuardianNotification
    {
        if ($notification->read_at === null) {
            $notification->update(['read_at' => now()]);
        }

        return $notification;
    }
}
