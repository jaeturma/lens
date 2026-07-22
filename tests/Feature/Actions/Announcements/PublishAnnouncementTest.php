<?php

use App\Actions\Announcements\PublishAnnouncement;
use App\Enums\AnnouncementStatus;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Models\Announcement;

test('publishing a draft sets status and published_at', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    $published = (new PublishAnnouncement)($announcement);

    expect($published->status)->toBe(AnnouncementStatus::Published);
    expect($published->published_at)->not->toBeNull();
});

test('publishing an already-published announcement is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Published, 'published_at' => now()]);

    expect(fn () => (new PublishAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});

test('publishing a withdrawn announcement is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Withdrawn]);

    expect(fn () => (new PublishAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});

test('publishing an expired announcement is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Expired]);

    expect(fn () => (new PublishAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});
