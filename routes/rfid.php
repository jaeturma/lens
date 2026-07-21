<?php

use App\Http\Controllers\RfidCards\DeactivateRfidCardController;
use App\Http\Controllers\RfidCards\ReplaceRfidCardController;
use App\Http\Controllers\RfidCards\RfidCardController;
use App\Http\Controllers\RfidDevices\ActivateRfidDeviceController;
use App\Http\Controllers\RfidDevices\RevokeRfidDeviceController;
use App\Http\Controllers\RfidDevices\RfidDeviceController;
use App\Http\Controllers\RfidScans\RfidScanController;
use Illuminate\Support\Facades\Route;

Route::middleware(['auth', 'verified'])->group(function () {
    Route::resource('rfid-devices', RfidDeviceController::class)->except('destroy');
    Route::patch('rfid-devices/{rfid_device}/activate', ActivateRfidDeviceController::class)->name('rfid-devices.activate');
    Route::patch('rfid-devices/{rfid_device}/revoke', RevokeRfidDeviceController::class)->name('rfid-devices.revoke');

    Route::resource('rfid-cards', RfidCardController::class)->only(['index', 'create', 'store']);
    Route::patch('rfid-cards/{card}/deactivate', DeactivateRfidCardController::class)->name('rfid-cards.deactivate');
    Route::patch('rfid-cards/{card}/replace', ReplaceRfidCardController::class)->name('rfid-cards.replace');

    Route::get('rfid-scans', [RfidScanController::class, 'index'])->name('rfid-scans.index');
});
