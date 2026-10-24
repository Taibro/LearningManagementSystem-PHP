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
        Schema::table('users', function (Blueprint $table) {
            $table->string('user_code')->nullable()->unique()->after('id');
            $table->enum('role', ['student', 'lecturer', 'admin'])->default('student')->after('email');
            $table->string('phone', 20)->nullable()->after('role');
            $table->enum('gender', ['male', 'female', 'other'])->nullable()->after('phone');
            $table->date('date_of_birth')->nullable()->after('gender');
            $table->string('class_name')->nullable()->after('date_of_birth');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'user_code',
                'role',
                'phone',
                'gender',
                'date_of_birth',
                'class_name',
            ]);
        });
    }
};
