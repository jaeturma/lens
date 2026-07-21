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
        Schema::create('rfid_devices', function (Blueprint $table) {
            $table->id();
            $table->string('device_code')->unique();
            $table->string('location');
            $table->string('direction_mode');
            $table->string('secret');
            $table->string('status')->default('active');
            $table->timestamp('last_activity_at')->nullable();
            $table->timestamps();

            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rfid_devices');
    }
};
