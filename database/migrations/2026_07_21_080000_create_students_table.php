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
        Schema::create('students', function (Blueprint $table) {
            $table->id();
            $table->uuid('uuid')->unique();
            $table->string('lrn', 12)->unique();
            $table->string('student_number', 50)->unique();
            $table->string('name');
            $table->string('sex');
            $table->string('grade');
            $table->string('section');
            $table->string('school_year');
            $table->string('status')->default('active');
            $table->string('photo_url')->nullable();
            $table->timestamps();

            $table->index('status');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('students');
    }
};
