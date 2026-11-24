<?php

use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

test('student portal extension migration runs up and down cleanly', function () {
    Config::set('database.default', 'sqlite');
    Config::set('database.connections.sqlite.database', ':memory:');
    DB::purge('sqlite');

    $schema = Schema::connection('sqlite');

    $schema->create('schools', function (Blueprint $table): void {
        $table->increments('id');
        $table->string('code')->unique();
        $table->string('name');
    });

    $schema->create('departments', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->string('name');
    });

    $schema->create('courses', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->string('code');
        $table->string('name');
    });

    $schema->create('users', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->string('email');
    });

    $schema->create('students', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->integer('user_id');
        $table->string('student_code');
    });

    $schema->create('enrollments', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->integer('class_id');
        $table->integer('student_id');
        $table->string('status')->default('ENROLLED');
    });

    $schema->create('schedule_exceptions', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->integer('schedule_id');
    });

    $schema->create('tuition_payments', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->integer('invoice_id');
        $table->string('payment_method')->default('QR_CODE');
        $table->string('status')->default('SUCCESS');
    });

    $schema->create('student_semester_summaries', function (Blueprint $table): void {
        $table->increments('id');
        $table->integer('school_id');
        $table->integer('student_id');
        $table->integer('semester_id');
    });

    $migration = require database_path('migrations/2026_11_24_000001_extend_schema_for_student_portal.php');

    $migration->up();

    expect($schema->hasColumn('students', 'citizen_id_number'))->toBeTrue()
        ->and($schema->hasColumn('enrollments', 'enrollment_type'))->toBeTrue()
        ->and($schema->hasColumns('schedule_exceptions', ['new_start_period', 'new_end_period']))->toBeTrue()
        ->and($schema->hasColumns('tuition_payments', ['course_data', 'expires_at']))->toBeTrue()
        ->and($schema->hasColumn('student_semester_summaries', 'scholarship_amount'))->toBeTrue()
        ->and($schema->hasTable('curriculum_courses'))->toBeTrue()
        ->and($schema->hasColumns('curriculum_courses', [
            'id',
            'curriculum_courses_id',
            'school_id',
            'department_id',
            'major',
            'semester_number',
            'course_id',
            'is_mandatory',
            'elective_group',
            'elective_required_credits',
        ]))->toBeTrue();

    // Idempotent second run should not throw
    $migration->up();

    $migration->down();

    expect($schema->hasColumn('students', 'citizen_id_number'))->toBeFalse()
        ->and($schema->hasColumn('enrollments', 'enrollment_type'))->toBeFalse()
        ->and($schema->hasColumn('schedule_exceptions', 'new_start_period'))->toBeFalse()
        ->and($schema->hasColumn('schedule_exceptions', 'new_end_period'))->toBeFalse()
        ->and($schema->hasColumn('tuition_payments', 'course_data'))->toBeFalse()
        ->and($schema->hasColumn('tuition_payments', 'expires_at'))->toBeFalse()
        ->and($schema->hasColumn('student_semester_summaries', 'scholarship_amount'))->toBeFalse()
        ->and($schema->hasTable('curriculum_courses'))->toBeFalse();
});
