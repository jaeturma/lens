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
        Schema::table('rfid_scans', function (Blueprint $table) {
            $table->string('classification')->default('valid')->after('request_id');

            $table->index('classification');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('rfid_scans', function (Blueprint $table) {
            $table->dropIndex(['classification']);
            $table->dropColumn('classification');
        });
    }
};
