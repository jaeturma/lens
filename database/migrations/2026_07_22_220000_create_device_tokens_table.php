<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * No school_id column — this Laravel installation is bound to exactly
     * one school (docs/SECURITY.md), so every token registered through it
     * is already implicitly school-bound; the `school.mobile` middleware
     * on the registration/revocation routes is what actually enforces it
     * (maintenance mode, mobile-disabled, minimum app version — the same
     * gate login and sync already use).
     */
    public function up(): void
    {
        Schema::create('device_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('guardian_id')->constrained()->cascadeOnDelete();
            $table->string('token')->unique();
            $table->string('status')->default('active');
            $table->timestamp('revoked_at')->nullable();
            $table->timestamps();

            $table->index(['guardian_id', 'status']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('device_tokens');
    }
};
