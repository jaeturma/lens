<?php

use App\Models\AttendanceRule;
use App\Models\School;
use App\Models\SchoolSettings;
use Illuminate\Support\Carbon;

function attendanceRuleForTimezone(string $timezone): AttendanceRule
{
    $school = School::factory()->create();
    SchoolSettings::factory()->for($school)->create(['timezone' => $timezone]);

    return AttendanceRule::factory()->for($school)->create([
        'arrival_cutoff_time' => '07:30:00',
        'departure_time' => '16:00:00',
        'absence_cutoff_time' => '10:00:00',
    ]);
}

test('isOperatingDay checks the configured weekday set', function () {
    $rule = AttendanceRule::factory()->create(['operating_days' => [1, 2, 3, 4, 5]]);

    $monday = Carbon::parse('2026-07-20');
    $sunday = Carbon::parse('2026-07-19');

    expect($rule->isOperatingDay($monday))->toBeTrue();
    expect($rule->isOperatingDay($sunday))->toBeFalse();
});

test('arrivalCutoffFor combines the date and time in the school\'s timezone, not UTC', function () {
    $rule = attendanceRuleForTimezone('Asia/Manila');

    $cutoff = $rule->arrivalCutoffFor(Carbon::parse('2026-07-22'));

    // 07:30 in Asia/Manila (UTC+8) is 23:30 UTC on the previous day.
    expect($cutoff->timezone->getName())->toBe('Asia/Manila');
    expect($cutoff->utc()->toIso8601String())->toBe('2026-07-21T23:30:00+00:00');
});

test('departureTimeFor and absenceCutoffFor are also timezone-correct', function () {
    $rule = attendanceRuleForTimezone('America/New_York');

    $departure = $rule->departureTimeFor(Carbon::parse('2026-07-22'));
    $absence = $rule->absenceCutoffFor(Carbon::parse('2026-07-22'));

    // America/New_York is UTC-4 in July (daylight saving time).
    expect($departure->utc()->toIso8601String())->toBe('2026-07-22T20:00:00+00:00');
    expect($absence->utc()->toIso8601String())->toBe('2026-07-22T14:00:00+00:00');
});

test('a different timezone on the same date produces a different UTC instant', function () {
    $utcRule = attendanceRuleForTimezone('UTC');
    $manilaRule = attendanceRuleForTimezone('Asia/Manila');

    $date = Carbon::parse('2026-07-22');

    expect($utcRule->arrivalCutoffFor($date)->utc()->toIso8601String())
        ->not->toBe($manilaRule->arrivalCutoffFor($date)->utc()->toIso8601String());
});
