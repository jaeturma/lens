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
        Schema::create('rfid_cards', function (Blueprint $table) {
            $table->id();
            $table->string('uid');
            $table->foreignId('student_id')->constrained()->cascadeOnDelete();
            $table->string('status')->default('active');
            $table->string('active_uid')->nullable()->storedAs("case when status = 'active' then uid else null end");
            $table->timestamps();

            $table->unique('active_uid');
            $table->index('uid');
            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('rfid_cards');
    }
};
