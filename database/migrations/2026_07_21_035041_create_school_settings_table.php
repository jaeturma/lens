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
        Schema::create('school_settings', function (Blueprint $table) {
            $table->id();
            $table->foreignId('school_id')->unique()->constrained()->cascadeOnDelete();
            $table->string('timezone')->default('Asia/Manila');
            $table->boolean('mobile_enabled')->default(true);
            $table->boolean('maintenance_mode')->default(false);
            $table->string('maintenance_message')->nullable();
            $table->boolean('notifications_enabled')->default(true);
            $table->string('minimum_app_version')->default('0.1.0');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('school_settings');
    }
};
