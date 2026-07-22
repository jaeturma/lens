<?php

use App\Enums\StudentStatus;
use App\Models\AttendanceDailySummary;
use App\Models\AttendanceRule;
use App\Models\Student;

test('the attendance:mark-absences command marks absences and reports the count', function () {
    $school = bindSchool(['timezone' => 'UTC']);
    AttendanceRule::factory()->for($school)->create(['absence_cutoff_time' => '10:00:00']);
    $student = Student::factory()->create(['status' => StudentStatus::Active]);

    $this->travelTo('2026-07-20 10:00:01');

    $this->artisan('attendance:mark-absences')
        ->expectsOutputToContain('Marked 1 student(s) absent.')
        ->assertSuccessful();

    $summary = AttendanceDailySummary::query()->where('student_id', $student->id)->firstOrFail();
    expect($summary->is_absent)->toBeTrue();
});
