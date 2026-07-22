<?php

namespace App\Console\Commands;

use App\Actions\Attendance\MarkDailyAbsences;
use Illuminate\Console\Command;

class MarkDailyAttendanceAbsences extends Command
{
    protected $signature = 'attendance:mark-absences';

    protected $description = 'Mark active students with no arrival today as absent, once the school\'s configured absence cutoff has passed';

    public function handle(MarkDailyAbsences $markDailyAbsences): int
    {
        $marked = $markDailyAbsences();

        $this->info("Marked {$marked} student(s) absent.");

        return self::SUCCESS;
    }
}
