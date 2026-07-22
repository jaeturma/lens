<?php

use App\Enums\AnnouncementStatus;
use App\Models\Announcement;

test('the announcements:expire command expires due announcements and reports the count', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Published,
        'published_at' => now()->subDays(2),
        'expires_at' => now()->subDay(),
    ]);

    $this->artisan('announcements:expire')
        ->expectsOutputToContain('Expired 1 announcement(s).')
        ->assertSuccessful();

    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Expired);
});
