<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     *
     * Table is deliberately not named `notifications` — App\Models\User
     * uses Laravel's Notifiable trait (unused today, but present), which
     * defaults to exactly that table name for its own database-channel
     * notifications. Naming this table `guardian_notifications` avoids a
     * silent schema collision if that trait's database channel is ever
     * used later.
     */
    public function up(): void
    {
        Schema::create('guardian_notifications', function (Blueprint $table) {
            $table->id();
            $table->uuid()->unique();
            $table->foreignId('guardian_id')->constrained()->cascadeOnDelete();
            $table->string('type');
            $table->string('title');
            $table->text('body');
            $table->json('payload')->nullable();
            $table->timestamp('read_at')->nullable();
            $table->string('delivery_status')->default('pending');
            $table->timestamps();

            $table->index(['guardian_id', 'read_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('guardian_notifications');
    }
};
