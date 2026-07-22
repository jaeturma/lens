<?php

namespace App\Console\Commands;

use App\Actions\Announcements\ExpireDueAnnouncements;
use Illuminate\Console\Command;

class ExpireAnnouncements extends Command
{
    protected $signature = 'announcements:expire';

    protected $description = 'Transition every published announcement past its expiration time to Expired';

    public function handle(ExpireDueAnnouncements $expireDueAnnouncements): int
    {
        $expired = $expireDueAnnouncements();

        $this->info("Expired {$expired} announcement(s).");

        return self::SUCCESS;
    }
}
