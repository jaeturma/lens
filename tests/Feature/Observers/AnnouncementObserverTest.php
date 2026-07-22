<?php

use App\Actions\Announcements\ExpireDueAnnouncements;
use App\Actions\Announcements\PublishAnnouncement;
use App\Actions\Announcements\WithdrawAnnouncement;
use App\Enums\AnnouncementStatus;
use App\Enums\SyncChangeAction;
use App\Models\Announcement;
use App\Models\SyncChange;

test('creating a draft records no sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    $this->assertDatabaseMissing('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
    ]);
});

test('editing a draft records no sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    $announcement->update(['title' => 'Updated draft title']);

    $this->assertDatabaseMissing('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
    ]);
});

test('publishing a draft records a created sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);

    (new PublishAnnouncement)($announcement);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
        'action' => SyncChangeAction::Created->value,
    ]);
    expect(SyncChange::query()->where('resource_type', 'announcement')->count())->toBe(1);
});

test('editing an already-published announcement records an updated sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);
    (new PublishAnnouncement)($announcement);

    $announcement->update(['title' => 'Revised title']);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
        'action' => SyncChangeAction::Updated->value,
    ]);
});

test('withdrawing a published announcement records a revoked sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);
    (new PublishAnnouncement)($announcement);

    (new WithdrawAnnouncement)($announcement);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
        'action' => SyncChangeAction::Revoked->value,
    ]);
});

test('an automatically expired announcement records an expired sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Draft]);
    (new PublishAnnouncement)($announcement);
    $announcement->update(['expires_at' => now()->subDay()]);

    (new ExpireDueAnnouncements)();

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
        'action' => SyncChangeAction::Expired->value,
    ]);
});

test('a directly-created published announcement still records a created sync change', function () {
    $announcement = Announcement::factory()->create(['status' => AnnouncementStatus::Published, 'published_at' => now()]);

    $this->assertDatabaseHas('sync_changes', [
        'resource_type' => 'announcement',
        'resource_id' => $announcement->id,
        'action' => SyncChangeAction::Created->value,
    ]);
});
