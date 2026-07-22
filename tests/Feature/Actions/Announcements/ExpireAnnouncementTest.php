<?php

use App\Actions\Announcements\ExpireAnnouncement;
use App\Enums\AnnouncementStatus;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Models\Announcement;

test('a published announcement can be manually expired even with no expires_at set', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Published,
        'published_at' => now(),
        'expires_at' => null,
    ]);

    $expired = (new ExpireAnnouncement)($announcement);

    expect($expired->status)->toBe(AnnouncementStatus::Expired);
});

test('expiring a draft is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    expect(fn () => (new ExpireAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});

test('expiring an already-withdrawn announcement is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Withdrawn]);

    expect(fn () => (new ExpireAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});
