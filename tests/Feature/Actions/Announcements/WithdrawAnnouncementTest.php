<?php

use App\Actions\Announcements\WithdrawAnnouncement;
use App\Enums\AnnouncementStatus;
use App\Exceptions\Announcements\InvalidAnnouncementTransitionException;
use App\Models\Announcement;

test('withdrawing a published announcement sets status without touching published_at', function () {
    $publishedAt = now()->subDay();
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Published, 'published_at' => $publishedAt]);

    $withdrawn = (new WithdrawAnnouncement)($announcement);

    expect($withdrawn->status)->toBe(AnnouncementStatus::Withdrawn);
    expect($withdrawn->published_at->toDateTimeString())->toBe($publishedAt->toDateTimeString());
});

test('withdrawing a draft is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    expect(fn () => (new WithdrawAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});

test('withdrawing an already-withdrawn announcement is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Withdrawn]);

    expect(fn () => (new WithdrawAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});

test('withdrawing an expired announcement is rejected', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Expired]);

    expect(fn () => (new WithdrawAnnouncement)($announcement))
        ->toThrow(InvalidAnnouncementTransitionException::class);
});
