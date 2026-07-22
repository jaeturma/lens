<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * WP-08-04: `App\Actions\Rfid\IngestRfidScan`'s idempotency check
     * (same `rfid_device_id` + `request_id` returns the existing row) was a
     * plain check-then-act with no database-level backstop — two
     * near-simultaneous submissions of the same retried request (a real
     * possibility for a device retrying after a timed-out response) could
     * both pass the check before either committed, creating two raw scan
     * rows for what should be one idempotency key. This constraint makes a
     * duplicate physically impossible to insert; the action now catches
     * the resulting `UniqueConstraintViolationException` and returns
     * whichever row won the race.
     */
    public function up(): void
    {
        Schema::table('rfid_scans', function (Blueprint $table) {
            $table->unique(['rfid_device_id', 'request_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rfid_scans', function (Blueprint $table) {
            $table->dropUnique(['rfid_device_id', 'request_id']);
        });
    }
};
