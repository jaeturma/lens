<?php

namespace App\Actions\Attendance;

use App\Enums\AttendanceEventType;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidScanClassification;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\AttendanceRule;
use App\Models\RfidCard;
use App\Models\RfidScan;
use App\Models\School;
use Carbon\CarbonImmutable;
use Carbon\CarbonInterface;
use Illuminate\Support\Facades\DB;

class ProcessRfidScan
{
    public function __invoke(RfidScan $scan): ?AttendanceEvent
    {
        if ($scan->classification !== RfidScanClassification::Valid) {
            return null;
        }

        $existing = AttendanceEvent::query()->where('rfid_scan_id', $scan->id)->first();

        if ($existing) {
            return $existing;
        }

        $card = RfidCard::query()->where('active_uid', $scan->uid)->first();

        if (! $card) {
            return null;
        }

        $school = School::query()->with('settings')->first();
        $timezone = ($school && $school->settings) ? $school->settings->timezone : 'UTC';
        $date = $scan->created_at->copy()->setTimezone($timezone)->toDateString();

        return DB::transaction(function () use ($scan, $card, $date, $timezone) {
            // Locked to the day's existing summary (if any) so the
            // both-direction toggle and the first-arrival-wins rule below
            // both decide against the same up-to-date state.
            $summary = AttendanceDailySummary::query()
                ->where('student_id', $card->student_id)
                ->whereDate('date', $date)
                ->lockForUpdate()
                ->first();

            $eventType = match ($scan->device->direction_mode) {
                RfidDeviceDirectionMode::Entry => AttendanceEventType::Arrival,
                RfidDeviceDirectionMode::Exit => AttendanceEventType::Departure,
                // A bidirectional device has no fixed meaning per tap, so it
                // toggles off the student's own day so far: no arrival yet
                // today means this tap is the arrival; once an arrival is
                // recorded, every further tap that day is a departure (the
                // same "most-recent exit wins" rule Exit-mode devices use),
                // covering a student who leaves and returns.
                RfidDeviceDirectionMode::Both => $summary?->arrival_event_id === null
                    ? AttendanceEventType::Arrival
                    : AttendanceEventType::Departure,
            };

            $isLate = $eventType === AttendanceEventType::Arrival
                && $this->isLateArrival($scan->created_at, $date, $timezone);

            $event = AttendanceEvent::create([
                'rfid_scan_id' => $scan->id,
                'student_id' => $card->student_id,
                'rfid_device_id' => $scan->rfid_device_id,
                'event_type' => $eventType,
                'occurred_at' => $scan->created_at,
                'is_late' => $isLate,
            ]);

            $this->updateDailySummary($event, $summary, $date);

            return $event;
        });
    }

    /**
     * An already-recorded arrival for the day is never replaced by a later
     * one (the "first entry of the day" rule) — repeat entry taps still get
     * their own AttendanceEvent for the audit trail, they just don't change
     * the summary. A departure always takes the most recent exit-type event
     * of the day, matching WP-04-02's original behavior.
     *
     * Recording an arrival also clears a same-day `is_absent` mark (WP-04-04
     * may have already run for the day before this — genuinely late but
     * present — arrival came in): the student is present, so the earlier
     * absence mark must not stand.
     */
    private function updateDailySummary(AttendanceEvent $event, ?AttendanceDailySummary $summary, string $date): void
    {
        if ($event->event_type === AttendanceEventType::Arrival && $summary?->arrival_event_id !== null) {
            return;
        }

        $column = match ($event->event_type) {
            AttendanceEventType::Arrival => 'arrival_event_id',
            AttendanceEventType::Departure => 'departure_event_id',
        };

        $attributes = [$column => $event->id];

        if ($event->event_type === AttendanceEventType::Arrival) {
            $attributes['is_absent'] = false;
        }

        if ($summary) {
            $summary->update($attributes);
        } else {
            AttendanceDailySummary::create([
                'student_id' => $event->student_id,
                'date' => $date,
                ...$attributes,
            ]);
        }
    }

    /**
     * No configured AttendanceRule means the school hasn't set an arrival
     * cutoff yet, so nothing is ever flagged late — the same "unconfigured
     * means unchanged" default WP-04-01's duplicate-window fallback uses,
     * rather than guessing a cutoff.
     */
    private function isLateArrival(CarbonInterface $occurredAt, string $date, string $timezone): bool
    {
        $rule = AttendanceRule::query()->first();

        if (! $rule) {
            return false;
        }

        $cutoff = $rule->arrivalCutoffFor(CarbonImmutable::parse($date, $timezone));

        return $occurredAt->greaterThan($cutoff);
    }
}
