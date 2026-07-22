<?php

namespace App\Jobs;

use App\Enums\DeviceTokenStatus;
use App\Enums\NotificationDeliveryStatus;
use App\Models\DeviceToken;
use App\Models\GuardianNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Throwable;

/**
 * Sends a minimal, data-only push signal — never the notification's own
 * title/body, and never any attendance/announcement content — to every
 * active device token of the notification's guardian. The signal only
 * tells the app "go sync," it is never the authoritative source of what
 * happened; the real content is App\Models\GuardianNotification itself,
 * fetched afterward the same way every other resource in this app is
 * (bootstrap/incremental sync — WP-06-06's job to wire up).
 */
class SendPushSignal implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(public readonly GuardianNotification $notification) {}

    public function handle(Messaging $messaging): void
    {
        $tokens = array_values(
            DeviceToken::query()
                ->where('guardian_id', $this->notification->guardian_id)
                ->where('status', DeviceTokenStatus::Active)
                ->pluck('token')
                ->all(),
        );

        // No device to signal yet — left as Pending (not Failed: no
        // delivery attempt was actually made) rather than inventing a
        // third "nothing to do" status the enum doesn't have.
        if ($tokens === []) {
            return;
        }

        $message = CloudMessage::new()->withData([
            'type' => 'sync_signal',
            'notification_type' => $this->notification->type->value,
        ]);

        try {
            $report = $messaging->sendMulticast($message, $tokens);
            $delivered = $report->successes()->count() > 0;
        } catch (Throwable $exception) {
            // Firebase being unreachable, misconfigured, or genuinely
            // rejecting the request are all the same outcome here: the
            // GuardianNotification row is never touched beyond its own
            // delivery_status — "failure does not delete notification
            // records." Invalid/unknown-token handling
            // ($report->invalidTokens()) is deliberately not acted on
            // here — deactivating a token on a delivery failure is
            // WP-06-06's own scope item ("invalid-token deactivation"),
            // not this package's.
            Log::warning('Push signal delivery failed.', [
                'guardian_notification_id' => $this->notification->id,
                'exception' => $exception->getMessage(),
            ]);
            $delivered = false;
        }

        $this->notification->update([
            'delivery_status' => $delivered ? NotificationDeliveryStatus::Sent : NotificationDeliveryStatus::Failed,
        ]);
    }
}
