<?php

use App\Enums\AnnouncementStatus;
use App\Models\Announcement;
use Illuminate\Support\Str;

test('an announcement gets a uuid and defaults to draft on creation', function () {
    $announcement = Announcement::factory()->create(['status' => null]);

    expect($announcement->uuid)->not->toBeEmpty();
    expect($announcement->status)->toBe(AnnouncementStatus::Draft);
});

test('an announcement uuid is immutable', function () {
    $announcement = Announcement::factory()->create();

    $announcement->uuid = (string) Str::uuid();
    $announcement->save();
})->throws(LogicException::class);
