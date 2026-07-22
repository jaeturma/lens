<?php

namespace App\Jobs;

use App\Enums\DeviceTokenStatus;
use App\Enums\NotificationDeliveryStatus;
use App\Models\DeviceToken;
use App\Models\GuardianNotification;
use App\Models\PushDeliveryAttempt;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\MulticastSendReport;
use Throwable;

/**
 * Sends a minimal, data-only push signal — never the notification's own
 * title/body, and never any attendance/announcement content — to every
 * active device token of the notification's guardian. The signal only
 * tells the app "go sync," it is never the authoritative source of what
 * happened; the real content is App\Models\GuardianNotification itself,
 * fetched afterward the same way every other resource in this app is
 * (bootstrap/incremental sync — App\Actions\Sync\ScopeChangesToGuardian's
 * guardian_notification branch, WP-06-06).
 *
 * One attempt per dispatch — no built-in Laravel job retry ($tries/
 * backoff). "Retry state" (WP-06-06's own scope item) is instead a
 * scheduled sweep (App\Actions\Notifications\RetryFailedPushSignals,
 * `notifications:retry-failed-push`) re-dispatching this same job for
 * still-Failed notifications, the same "explicit scheduled re-check"
 * shape as attendance:mark-absences/announcements:expire — chosen over
 * queue-internal retry bookkeeping because every attempt this way is a
 * plain, directly testable handle() call, and each retry naturally
 * re-reads the guardian's *currently* active tokens rather than
 * replaying a stale token list from the first attempt.
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
        // delivery attempt was actually made), and nothing is logged —
        // there is no attempt to log. Not a candidate for the retry sweep
        // either, since it only reconsiders Failed notifications.
        if ($tokens === []) {
            return;
        }

        $message = CloudMessage::new()->withData([
            'type' => 'sync_signal',
            'notification_type' => $this->notification->type->value,
        ]);

        try {
            $report = $messaging->sendMulticast($message, $tokens);
            $this->deactivateInvalidTokens($report);
            $delivered = $report->successes()->count() > 0;
            $errorMessage = $delivered ? null : 'Firebase reported no successful deliveries.';
        } catch (Throwable $exception) {
            // Firebase being unreachable, misconfigured, or genuinely
            // rejecting the request are all the same outcome here: the
            // GuardianNotification row is never touched beyond its own
            // delivery_status — "failure does not delete notification
            // records."
            Log::warning('Push signal delivery failed.', [
                'guardian_notification_id' => $this->notification->id,
                'exception' => $exception->getMessage(),
            ]);
            $delivered = false;
            $errorMessage = $exception->getMessage();
        }

        PushDeliveryAttempt::create([
            'guardian_notification_id' => $this->notification->id,
            'attempt_number' => $this->notification->pushDeliveryAttempts()->count() + 1,
            'succeeded' => $delivered,
            'error_message' => $errorMessage,
        ]);

        $this->notification->update([
            'delivery_status' => $delivered ? NotificationDeliveryStatus::Sent : NotificationDeliveryStatus::Failed,
        ]);
    }

    /**
     * "Invalid tokens are deactivated safely": only tokens Firebase's own
     * response has specifically identified as invalid or unknown — never
     * as a side effect of a general delivery exception, which says
     * nothing about any individual token's validity and affects every
     * token in the batch indiscriminately.
     */
    private function deactivateInvalidTokens(MulticastSendReport $report): void
    {
        $badTokens = [...$report->invalidTokens(), ...$report->unknownTokens()];

        if ($badTokens === []) {
            return;
        }

        DeviceToken::query()
            ->whereIn('token', $badTokens)
            ->update(['status' => DeviceTokenStatus::Deactivated, 'revoked_at' => now()]);
    }
}
