<?php

use App\Http\Controllers\Announcements\AnnouncementController;
use App\Http\Controllers\Announcements\ExpireAnnouncementController;
use App\Http\Controllers\Announcements\PublishAnnouncementController;
use App\Http\Controllers\Announcements\WithdrawAnnouncementController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('announcements', AnnouncementController::class)->except(['destroy']);

    Route::patch('announcements/{announcement}/publish', PublishAnnouncementController::class)->name('announcements.publish');
    Route::patch('announcements/{announcement}/withdraw', WithdrawAnnouncementController::class)->name('announcements.withdraw');
    Route::patch('announcements/{announcement}/expire', ExpireAnnouncementController::class)->name('announcements.expire');
});
