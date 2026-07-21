<?php

namespace App\Actions\Attendance;

use App\Enums\AttendanceEventType;
use App\Enums\RfidDeviceDirectionMode;
use App\Enums\RfidScanClassification;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceEvent;
use App\Models\RfidCard;
use App\Models\RfidScan;
use App\Models\School;
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

        $eventType = match ($scan->device->direction_mode) {
            RfidDeviceDirectionMode::Entry => AttendanceEventType::Arrival,
            RfidDeviceDirectionMode::Exit => AttendanceEventType::Departure,
            // Disambiguating a bidirectional device's scans is WP-04-03's
            // job; leave the scan unprocessed until that rule exists.
            RfidDeviceDirectionMode::Both => null,
        };

        if ($eventType === null) {
            return null;
        }

        $card = RfidCard::query()->where('active_uid', $scan->uid)->first();

        if (! $card) {
            return null;
        }

        return DB::transaction(function () use ($scan, $card, $eventType) {
            $event = AttendanceEvent::create([
                'rfid_scan_id' => $scan->id,
                'student_id' => $card->student_id,
                'rfid_device_id' => $scan->rfid_device_id,
                'event_type' => $eventType,
                'occurred_at' => $scan->created_at,
            ]);

            $this->updateDailySummary($event);

            return $event;
        });
    }

    private function updateDailySummary(AttendanceEvent $event): void
    {
        $school = School::query()->with('settings')->first();
        $timezone = ($school && $school->settings) ? $school->settings->timezone : 'UTC';
        $date = $event->occurred_at->copy()->setTimezone($timezone)->toDateString();

        $column = match ($event->event_type) {
            AttendanceEventType::Arrival => 'arrival_event_id',
            AttendanceEventType::Departure => 'departure_event_id',
        };

        // A plain where(['date' => $date]) match (e.g. via updateOrCreate)
        // is not reliable against a `date`-cast column across write/read
        // formatting, so the existing row is looked up with whereDate()
        // explicitly instead.
        $summary = AttendanceDailySummary::query()
            ->where('student_id', $event->student_id)
            ->whereDate('date', $date)
            ->first();

        if ($summary) {
            $summary->update([$column => $event->id]);
        } else {
            AttendanceDailySummary::create([
                'student_id' => $event->student_id,
                'date' => $date,
                $column => $event->id,
            ]);
        }
    }
}
