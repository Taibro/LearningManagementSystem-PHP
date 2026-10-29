<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

return new class extends Migration
{
    public function up(): void
    {
        $sqlPath = database_path('sql/01_lms_schema.sql');
        if (! File::exists($sqlPath)) {
            throw new RuntimeException("Không tìm thấy file SQL tại: {$sqlPath}");
        }

        DB::unprepared(File::get($sqlPath));
    }

    public function down(): void
    {
        $tables = [
            'teacher_salary_detail', 'teacher_salary_sheet', 'salary_grade', 'salary_config',
            'class_teacher', 'teacher_evaluations', 'audit_logs', 'system_error_logs',
            'saas_invoices', 'saas_subscriptions', 'saas_plans', 'class_materials',
            'teacher_declarations', 'student_semester_summaries', 'tuition_payments',
            'tuition_invoices', 'notifications', 'attendance_records', 'enrollments',
            'schedule_exceptions', 'schedules', 'classes', 'rooms', 'courses',
            'students', 'teachers', 'user_roles', 'users', 'role', 'departments',
            'semesters', 'academic_years', 'school_branches', 'schools',
        ];

        foreach ($tables as $table) {
            DB::statement("DROP TABLE IF EXISTS {$table} CASCADE;");
        }

        DB::statement('DROP FUNCTION IF EXISTS update_updated_at_column() CASCADE;');
    }
};

