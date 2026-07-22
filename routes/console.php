<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Schedule;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

// The absence cutoff is a configurable time-of-day (AttendanceRule), not a
// fixed schedule time, so this runs frequently and the action itself
// decides whether "now" is past today's cutoff — safe to run repeatedly.
Schedule::command('attendance:mark-absences')->everyFifteenMinutes();

// expires_at is an admin-set instant, not a fixed daily time, so this
// polls frequently rather than running once at a fixed clock time.
Schedule::command('announcements:expire')->everyFifteenMinutes();
