<?php

namespace Database\Factories;

use App\Enums\AttendanceEventType;
use App\Models\AttendanceEvent;
use App\Models\RfidDevice;
use App\Models\RfidScan;
use App\Models\Student;
use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends Factory<AttendanceEvent>
 */
class AttendanceEventFactory extends Factory
{
    protected $model = AttendanceEvent::class;

    /**
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'rfid_scan_id' => RfidScan::factory(),
            'student_id' => Student::factory(),
            'rfid_device_id' => RfidDevice::factory(),
            'event_type' => AttendanceEventType::Arrival,
            'occurred_at' => now(),
        ];
    }
}
