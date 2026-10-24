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
        Schema::create('semesters', function (Blueprint $table) {
            $table->id();
            $table->string('semester_code')->unique();
            $table->string('name');
            $table->year('academic_year_start');
            $table->year('academic_year_end');
            $table->decimal('tuition_fee_per_credit', 10, 2)->default(450000.00);
            $table->date('start_date');
            $table->date('end_date');
            $table->date('tuition_deadline')->nullable();
            $table->boolean('is_active')->default(false);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('semesters');
    }
};
