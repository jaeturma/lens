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
        Schema::create('push_delivery_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('guardian_notification_id')->constrained()->cascadeOnDelete();
            $table->unsignedInteger('attempt_number');
            $table->boolean('succeeded');
            $table->text('error_message')->nullable();
            $table->timestamp('created_at')->useCurrent();

            $table->index('guardian_notification_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('push_delivery_attempts');
    }
};
