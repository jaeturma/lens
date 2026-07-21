<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('rfid_scans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('rfid_device_id')->constrained()->restrictOnDelete();
            $table->string('uid');
            $table->timestamp('device_timestamp');
            $table->string('request_id');
            $table->timestamp('created_at')->useCurrent();

            $table->index('uid');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rfid_scans');
    }
};
