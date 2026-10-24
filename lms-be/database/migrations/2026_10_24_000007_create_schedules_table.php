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
        Schema::create('schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('course_class_id')->constrained('course_classes')->onDelete('cascade');
            $table->foreignId('classroom_id')->constrained('classrooms')->onDelete('cascade');
            $table->tinyInteger('day_of_week'); // 2: Thu 2, ..., 8: Chu nhat
            $table->tinyInteger('shift')->nullable(); // Ca 1 -> Ca 5
            $table->tinyInteger('start_period'); // Tiet 1, 4, 7, 10, 13
            $table->tinyInteger('end_period'); // Tiet 3, 5, 6, 9, 11, 12, 15, 16
            $table->enum('lesson_type', ['theory', 'practice'])->default('theory');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('schedules');
    }
};
