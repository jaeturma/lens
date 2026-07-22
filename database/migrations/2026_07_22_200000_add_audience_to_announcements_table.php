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
        Schema::table('announcements', function (Blueprint $table) {
            $table->string('audience_type')->default('all')->after('status');
            $table->string('audience_grade')->nullable()->after('audience_type');
            $table->string('audience_section')->nullable()->after('audience_grade');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('announcements', function (Blueprint $table) {
            $table->dropColumn(['audience_type', 'audience_grade', 'audience_section']);
        });
    }
};
