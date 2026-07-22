<?php

use App\Actions\Announcements\ExpireDueAnnouncements;
use App\Enums\AnnouncementStatus;
use App\Models\Announcement;

test('a published announcement past its expiration is expired', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Published,
        'published_at' => now()->subDays(2),
        'expires_at' => now()->subDay(),
    ]);

    $count = (new ExpireDueAnnouncements)();

    expect($count)->toBe(1);
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Expired);
});

test('a published announcement not yet due is left alone', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Published,
        'published_at' => now(),
        'expires_at' => now()->addDay(),
    ]);

    $count = (new ExpireDueAnnouncements)();

    expect($count)->toBe(0);
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Published);
});

test('a published announcement with no expiration is never expired', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Published,
        'published_at' => now()->subYear(),
        'expires_at' => null,
    ]);

    $count = (new ExpireDueAnnouncements)();

    expect($count)->toBe(0);
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Published);
});

test('a draft past its expires_at is never expired', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Draft,
        'expires_at' => now()->subDay(),
    ]);

    $count = (new ExpireDueAnnouncements)();

    expect($count)->toBe(0);
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Draft);
});

test('an already-withdrawn announcement past its expires_at is left alone', function () {
    $announcement = Announcement::factory()->create([
        'status' => AnnouncementStatus::Withdrawn,
        'expires_at' => now()->subDay(),
    ]);

    $count = (new ExpireDueAnnouncements)();

    expect($count)->toBe(0);
    expect($announcement->fresh()->status)->toBe(AnnouncementStatus::Withdrawn);
});
