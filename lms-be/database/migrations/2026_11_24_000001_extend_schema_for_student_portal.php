<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $conn = $this->resolveDdlConnection();
        $schema = Schema::connection($conn);
        $db = DB::connection($conn);
        $isPgsql = $db->getDriverName() === 'pgsql';

        // 1. students.citizen_id_number
        if ($schema->hasTable('students') && ! $schema->hasColumn('students', 'citizen_id_number')) {
            $schema->table('students', function (Blueprint $table): void {
                $table->string('citizen_id_number', 20)->nullable();
            });
        }

        // 2. enrollments.enrollment_type ('NORMAL' | 'RETAKE' | 'IMPROVE')
        if ($schema->hasTable('enrollments') && ! $schema->hasColumn('enrollments', 'enrollment_type')) {
            $schema->table('enrollments', function (Blueprint $table): void {
                $table->string('enrollment_type', 20)->default('NORMAL');
            });

            if ($isPgsql) {
                $db->statement("
                    ALTER TABLE enrollments
                    DROP CONSTRAINT IF EXISTS chk_enr_type,
                    ADD CONSTRAINT chk_enr_type CHECK (enrollment_type IN ('NORMAL', 'RETAKE', 'IMPROVE'));
                ");
            }
        }

        // 3. schedule_exceptions.new_start_period & new_end_period
        if ($schema->hasTable('schedule_exceptions')) {
            $needsStart = ! $schema->hasColumn('schedule_exceptions', 'new_start_period');
            $needsEnd = ! $schema->hasColumn('schedule_exceptions', 'new_end_period');

            if ($needsStart || $needsEnd) {
                $schema->table('schedule_exceptions', function (Blueprint $table) use ($needsStart, $needsEnd): void {
                    if ($needsStart) {
                        $table->smallInteger('new_start_period')->nullable();
                    }
                    if ($needsEnd) {
                        $table->smallInteger('new_end_period')->nullable();
                    }
                });

                if ($isPgsql) {
                    $db->statement('
                        ALTER TABLE schedule_exceptions
                        DROP CONSTRAINT IF EXISTS chk_sexc_periods,
                        ADD CONSTRAINT chk_sexc_periods CHECK (
                            (new_start_period IS NULL AND new_end_period IS NULL)
                            OR (new_start_period >= 1 AND new_end_period >= new_start_period)
                        );
                    ');
                }
            }
        }

        // 4. tuition_payments: course_data (JSONB), expires_at, and extended status/payment_method checks
        if ($schema->hasTable('tuition_payments')) {
            $needsCourseData = ! $schema->hasColumn('tuition_payments', 'course_data');
            $needsExpiresAt = ! $schema->hasColumn('tuition_payments', 'expires_at');

            if ($needsCourseData || $needsExpiresAt) {
                $schema->table('tuition_payments', function (Blueprint $table) use ($needsCourseData, $needsExpiresAt, $isPgsql): void {
                    if ($needsCourseData) {
                        if ($isPgsql) {
                            $table->jsonb('course_data')->nullable();
                        } else {
                            $table->json('course_data')->nullable();
                        }
                    }
                    if ($needsExpiresAt) {
                        $table->timestamp('expires_at')->nullable();
                    }
                });
            }

            if ($isPgsql) {
                $this->dropColumnCheckConstraints($db, 'tuition_payments', 'payment_method');
                $this->dropColumnCheckConstraints($db, 'tuition_payments', 'status');

                $db->statement("
                    ALTER TABLE tuition_payments
                    ADD CONSTRAINT chk_pay_method CHECK (payment_method IN ('QR_CODE', 'BANK_TRANSFER', 'CASH', 'E_WALLET', 'VISA')),
                    ADD CONSTRAINT chk_pay_status CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED', 'CANCELLED'));
                ");

                $db->statement('
                    CREATE INDEX IF NOT EXISTS idx_pay_status_expires
                    ON tuition_payments (status, expires_at);
                ');
            }
        }

        // 5. student_semester_summaries.scholarship_amount
        if ($schema->hasTable('student_semester_summaries') && ! $schema->hasColumn('student_semester_summaries', 'scholarship_amount')) {
            $schema->table('student_semester_summaries', function (Blueprint $table): void {
                $table->decimal('scholarship_amount', 15, 2)->default(0.00);
            });

            if ($isPgsql) {
                $db->statement('
                    ALTER TABLE student_semester_summaries
                    DROP CONSTRAINT IF EXISTS chk_sum_scholarship_amount,
                    ADD CONSTRAINT chk_sum_scholarship_amount CHECK (scholarship_amount >= 0);
                ');
            }
        }

        // 6. curriculum_courses table + RLS policies
        if (! $schema->hasTable('curriculum_courses')) {
            $schema->create('curriculum_courses', function (Blueprint $table) use ($isPgsql): void {
                $table->increments('id');
                if ($isPgsql) {
                    $table->uuid('curriculum_courses_id')->unique();
                } else {
                    $table->string('curriculum_courses_id', 36)->unique();
                }
                $table->integer('school_id');
                $table->integer('department_id')->nullable();
                $table->string('major', 100)->nullable();
                $table->smallInteger('semester_number');
                $table->integer('course_id');
                $table->boolean('is_mandatory')->default(true);
                $table->smallInteger('elective_group')->default(0);
                $table->smallInteger('elective_required_credits')->nullable();
                $table->timestamp('created_at')->useCurrent();
                $table->timestamp('updated_at')->useCurrent();
                $table->integer('created_by')->nullable();
                $table->integer('updated_by')->nullable();

                $table->index(['school_id', 'department_id', 'major', 'semester_number'], 'idx_curr_lookup');

                $table->foreign('school_id', 'fk_curr_school')->references('id')->on('schools')->onDelete('cascade');
                $table->foreign('department_id', 'fk_curr_dept')->references('id')->on('departments')->onDelete('set null');
                $table->foreign('course_id', 'fk_curr_course')->references('id')->on('courses')->onDelete('cascade');
                $table->foreign('created_by', 'fk_curr_cby')->references('id')->on('users')->onDelete('set null');
                $table->foreign('updated_by', 'fk_curr_uby')->references('id')->on('users')->onDelete('set null');
            });

            if ($isPgsql) {
                $db->statement('
                    ALTER TABLE curriculum_courses
                    ALTER COLUMN curriculum_courses_id SET DEFAULT gen_random_uuid();
                ');
                $db->statement('
                    ALTER TABLE curriculum_courses
                    ADD CONSTRAINT chk_curr_semester_num CHECK (semester_number >= 1),
                    ADD CONSTRAINT chk_curr_elective_grp CHECK (elective_group >= 0);
                ');
                $db->statement("
                    CREATE UNIQUE INDEX IF NOT EXISTS uq_curr_course
                    ON curriculum_courses (school_id, COALESCE(department_id, 0), COALESCE(major, ''), course_id);
                ");

                $this->applyTenantRlsAndGrants($db, 'curriculum_courses');
            }
        }
    }

    public function down(): void
    {
        $conn = $this->resolveDdlConnection();
        $schema = Schema::connection($conn);
        $db = DB::connection($conn);
        $isPgsql = $db->getDriverName() === 'pgsql';

        // 6. Drop curriculum_courses
        $schema->dropIfExists('curriculum_courses');

        // 5. Drop student_semester_summaries.scholarship_amount
        if ($schema->hasTable('student_semester_summaries') && $schema->hasColumn('student_semester_summaries', 'scholarship_amount')) {
            if ($isPgsql) {
                $db->statement('ALTER TABLE student_semester_summaries DROP CONSTRAINT IF EXISTS chk_sum_scholarship_amount;');
            }
            $schema->table('student_semester_summaries', function (Blueprint $table): void {
                $table->dropColumn('scholarship_amount');
            });
        }

        // 4. Revert tuition_payments
        if ($schema->hasTable('tuition_payments')) {
            if ($isPgsql) {
                $db->statement('DROP INDEX IF EXISTS idx_pay_status_expires;');
                $this->dropColumnCheckConstraints($db, 'tuition_payments', 'payment_method');
                $this->dropColumnCheckConstraints($db, 'tuition_payments', 'status');

                $db->statement("UPDATE tuition_payments SET payment_method = 'BANK_TRANSFER' WHERE payment_method = 'VISA';");
                $db->statement("UPDATE tuition_payments SET status = 'FAILED' WHERE status = 'CANCELLED';");

                $db->statement("
                    ALTER TABLE tuition_payments
                    ADD CONSTRAINT tuition_payments_payment_method_check CHECK (payment_method IN ('QR_CODE', 'BANK_TRANSFER', 'CASH', 'E_WALLET')),
                    ADD CONSTRAINT tuition_payments_status_check CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED'));
                ");
            }

            $dropCols = array_values(array_filter([
                $schema->hasColumn('tuition_payments', 'course_data') ? 'course_data' : null,
                $schema->hasColumn('tuition_payments', 'expires_at') ? 'expires_at' : null,
            ]));
            if ($dropCols !== []) {
                $schema->table('tuition_payments', function (Blueprint $table) use ($dropCols): void {
                    $table->dropColumn($dropCols);
                });
            }
        }

        // 3. Revert schedule_exceptions
        if ($schema->hasTable('schedule_exceptions')) {
            if ($isPgsql) {
                $db->statement('ALTER TABLE schedule_exceptions DROP CONSTRAINT IF EXISTS chk_sexc_periods;');
            }
            $dropCols = array_values(array_filter([
                $schema->hasColumn('schedule_exceptions', 'new_start_period') ? 'new_start_period' : null,
                $schema->hasColumn('schedule_exceptions', 'new_end_period') ? 'new_end_period' : null,
            ]));
            if ($dropCols !== []) {
                $schema->table('schedule_exceptions', function (Blueprint $table) use ($dropCols): void {
                    $table->dropColumn($dropCols);
                });
            }
        }

        // 2. Revert enrollments
        if ($schema->hasTable('enrollments') && $schema->hasColumn('enrollments', 'enrollment_type')) {
            if ($isPgsql) {
                $db->statement('ALTER TABLE enrollments DROP CONSTRAINT IF EXISTS chk_enr_type;');
            }
            $schema->table('enrollments', function (Blueprint $table): void {
                $table->dropColumn('enrollment_type');
            });
        }

        // 1. Revert students
        if ($schema->hasTable('students') && $schema->hasColumn('students', 'citizen_id_number')) {
            $schema->table('students', function (Blueprint $table): void {
                $table->dropColumn('citizen_id_number');
            });
        }
    }

    private function resolveDdlConnection(): string
    {
        $conn = $this->getConnection();
        if ($conn !== null && $conn !== '') {
            return $conn;
        }

        $default = (string) config('database.default');
        if ($default === 'pgsql' && is_array(config('database.connections.pgsql_owner'))) {
            return 'pgsql_owner';
        }

        return $default;
    }

    private function dropColumnCheckConstraints(\Illuminate\Database\ConnectionInterface $db, string $table, string $column): void
    {
        $rows = $db->select(
            "SELECT c.conname
             FROM pg_constraint c
             JOIN pg_class t ON t.oid = c.conrelid
             JOIN pg_namespace n ON n.oid = t.relnamespace
             WHERE n.nspname = 'public'
               AND t.relname = ?
               AND c.contype = 'c'
               AND pg_get_constraintdef(c.oid) ILIKE ?",
            [$table, "%{$column}%"]
        );

        foreach ($rows as $row) {
            $constraintName = str_replace('"', '""', (string) $row->conname);
            $db->statement("ALTER TABLE \"{$table}\" DROP CONSTRAINT IF EXISTS \"{$constraintName}\";");
        }
    }

    private function applyTenantRlsAndGrants(\Illuminate\Database\ConnectionInterface $db, string $table): void
    {
        $db->statement("
            DO \$\$
            BEGIN
                IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'lms_app_role') THEN
                    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE {$table} TO lms_app_role;
                    GRANT USAGE, SELECT ON SEQUENCE {$table}_id_seq TO lms_app_role;
                END IF;

                IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'saas_admin_role') THEN
                    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE {$table} TO saas_admin_role;
                    GRANT USAGE, SELECT ON SEQUENCE {$table}_id_seq TO saas_admin_role;
                END IF;
            END
            \$\$;
        ");

        $hasRlsFuncs = $db->selectOne("
            SELECT EXISTS (
                SELECT 1 FROM pg_proc WHERE proname = 'current_school_id'
            ) AS has_school,
            EXISTS (
                SELECT 1 FROM pg_proc WHERE proname = 'is_saas_admin'
            ) AS has_saas
        ");

        if ($hasRlsFuncs && $hasRlsFuncs->has_school && $hasRlsFuncs->has_saas) {
            $db->statement("ALTER TABLE {$table} ENABLE ROW LEVEL SECURITY;");
            $db->statement("ALTER TABLE {$table} FORCE ROW LEVEL SECURITY;");

            $db->statement("DROP POLICY IF EXISTS tenant_isolation_select ON {$table};");
            $db->statement("DROP POLICY IF EXISTS tenant_isolation_insert ON {$table};");
            $db->statement("DROP POLICY IF EXISTS tenant_isolation_update ON {$table};");
            $db->statement("DROP POLICY IF EXISTS tenant_isolation_delete ON {$table};");

            $db->statement("CREATE POLICY tenant_isolation_select ON {$table} FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());");
            $db->statement("CREATE POLICY tenant_isolation_insert ON {$table} FOR INSERT WITH CHECK (school_id = current_school_id() OR is_saas_admin());");
            $db->statement("CREATE POLICY tenant_isolation_update ON {$table} FOR UPDATE USING (school_id = current_school_id() OR is_saas_admin()) WITH CHECK (school_id = current_school_id() OR is_saas_admin());");
            $db->statement("CREATE POLICY tenant_isolation_delete ON {$table} FOR DELETE USING (school_id = current_school_id() OR is_saas_admin());");
        }
    }
};
