<?php

use Illuminate\Database\ConnectionInterface;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        $ddlConnection = $this->resolveDdlConnection();
        $schema = Schema::connection($ddlConnection);
        $db = DB::connection($ddlConnection);
        $isPgsql = $db->getDriverName() === 'pgsql';

        if (! $schema->hasTable('image_uploads')) {
            $schema->create('image_uploads', function (Blueprint $table): void {
                $table->increments('id');
                $table->uuid('image_uploads_id')->unique();
                $table->unsignedInteger('school_id');
                $table->unsignedInteger('uploaded_by')->nullable();

                $table->string('disk', 30)->default('r2');
                $table->string('bucket', 120);
                $table->string('object_key', 500)->unique();
                $table->string('original_name', 255);
                $table->string('mime_type', 150);
                $table->unsignedBigInteger('file_size');

                $table->string('category', 50)->default('GENERAL');
                $table->string('visibility', 20)->default('PRIVATE');
                $table->string('status', 20)->default('PENDING');
                $table->string('etag', 128)->nullable();

                $table->timestamp('expires_at')->nullable();
                $table->timestamp('uploaded_at')->nullable();

                $table->unsignedInteger('created_by')->nullable();
                $table->unsignedInteger('updated_by')->nullable();
                $table->timestamps();

                $table->foreign('school_id')->references('id')->on('schools')->onDelete('cascade');
                $table->foreign('uploaded_by')->references('id')->on('users')->onDelete('set null');
                $table->foreign('created_by')->references('id')->on('users')->onDelete('set null');
                $table->foreign('updated_by')->references('id')->on('users')->onDelete('set null');

                $table->index(['school_id', 'status'], 'idx_image_uploads_school_status');
                $table->index(['school_id', 'category'], 'idx_image_uploads_school_category');
                $table->index('uploaded_by', 'idx_image_uploads_uploaded_by');
                $table->index(['status', 'expires_at'], 'idx_image_uploads_pending_expires');
            });

            if ($isPgsql) {
                $db->statement('ALTER TABLE image_uploads ALTER COLUMN image_uploads_id SET DEFAULT gen_random_uuid();');
                $db->statement('ALTER TABLE image_uploads ADD CONSTRAINT chk_image_uploads_file_size CHECK (file_size > 0);');
                $db->statement("ALTER TABLE image_uploads ADD CONSTRAINT chk_image_uploads_category CHECK (category IN ('AVATAR', 'SCHOOL_LOGO', 'CLASS_MATERIAL', 'TEACHER_EVIDENCE', 'GENERAL'));");
                $db->statement("ALTER TABLE image_uploads ADD CONSTRAINT chk_image_uploads_visibility CHECK (visibility IN ('PRIVATE', 'PUBLIC'));");
                $db->statement("ALTER TABLE image_uploads ADD CONSTRAINT chk_image_uploads_status CHECK (status IN ('PENDING', 'UPLOADED', 'FAILED', 'DELETED'));");

                $this->applyTenantRlsAndGrants($db, 'image_uploads');
            }
        }

        // 1. schools: add logo_upload_id FK and drop legacy logo_url
        if ($schema->hasTable('schools')) {
            if (! $schema->hasColumn('schools', 'logo_upload_id')) {
                $schema->table('schools', function (Blueprint $table): void {
                    $table->unsignedInteger('logo_upload_id')->nullable();
                    $table->foreign('logo_upload_id', 'fk_schools_logo_upload_id')
                        ->references('id')->on('image_uploads')->onDelete('set null');
                    $table->index('logo_upload_id', 'idx_schools_logo_upload_id');
                });
            }

            if ($schema->hasColumn('schools', 'logo_url')) {
                $schema->table('schools', function (Blueprint $table): void {
                    $table->dropColumn('logo_url');
                });
            }
        }

        // 2. users: add avatar_upload_id FK and drop legacy avatar_url
        if ($schema->hasTable('users')) {
            if (! $schema->hasColumn('users', 'avatar_upload_id')) {
                $schema->table('users', function (Blueprint $table): void {
                    $table->unsignedInteger('avatar_upload_id')->nullable();
                    $table->foreign('avatar_upload_id', 'fk_users_avatar_upload_id')
                        ->references('id')->on('image_uploads')->onDelete('set null');
                    $table->index('avatar_upload_id', 'idx_users_avatar_upload_id');
                });
            }

            if ($schema->hasColumn('users', 'avatar_url')) {
                $schema->table('users', function (Blueprint $table): void {
                    $table->dropColumn('avatar_url');
                });
            }
        }

        // 3. teacher_declarations: add evidence_upload_id FK and drop legacy evidence_url
        if ($schema->hasTable('teacher_declarations')) {
            if (! $schema->hasColumn('teacher_declarations', 'evidence_upload_id')) {
                $schema->table('teacher_declarations', function (Blueprint $table): void {
                    $table->unsignedInteger('evidence_upload_id')->nullable();
                    $table->foreign('evidence_upload_id', 'fk_teacher_declarations_evidence_upload_id')
                        ->references('id')->on('image_uploads')->onDelete('set null');
                    $table->index('evidence_upload_id', 'idx_teacher_declarations_evidence_upload_id');
                });
            }

            if ($schema->hasColumn('teacher_declarations', 'evidence_url')) {
                $schema->table('teacher_declarations', function (Blueprint $table): void {
                    $table->dropColumn('evidence_url');
                });
            }
        }

        // 4. class_materials: add file_upload_id FK and drop legacy file_url
        if ($schema->hasTable('class_materials')) {
            if (! $schema->hasColumn('class_materials', 'file_upload_id')) {
                $schema->table('class_materials', function (Blueprint $table): void {
                    $table->unsignedInteger('file_upload_id')->nullable();
                    $table->foreign('file_upload_id', 'fk_class_materials_file_upload_id')
                        ->references('id')->on('image_uploads')->onDelete('set null');
                    $table->index('file_upload_id', 'idx_class_materials_file_upload_id');
                });
            }

            if ($schema->hasColumn('class_materials', 'file_url')) {
                $schema->table('class_materials', function (Blueprint $table): void {
                    $table->dropColumn('file_url');
                });
            }
        }
    }

    public function down(): void
    {
        $ddlConnection = $this->resolveDdlConnection();
        $schema = Schema::connection($ddlConnection);

        if ($schema->hasTable('class_materials')) {
            if (! $schema->hasColumn('class_materials', 'file_url')) {
                $schema->table('class_materials', function (Blueprint $table): void {
                    $table->string('file_url', 500)->nullable();
                });
            }

            if ($schema->hasColumn('class_materials', 'file_upload_id')) {
                $schema->table('class_materials', function (Blueprint $table): void {
                    $table->dropForeign('fk_class_materials_file_upload_id');
                    $table->dropIndex('idx_class_materials_file_upload_id');
                    $table->dropColumn('file_upload_id');
                });
            }
        }

        if ($schema->hasTable('teacher_declarations')) {
            if (! $schema->hasColumn('teacher_declarations', 'evidence_url')) {
                $schema->table('teacher_declarations', function (Blueprint $table): void {
                    $table->string('evidence_url', 500)->nullable();
                });
            }

            if ($schema->hasColumn('teacher_declarations', 'evidence_upload_id')) {
                $schema->table('teacher_declarations', function (Blueprint $table): void {
                    $table->dropForeign('fk_teacher_declarations_evidence_upload_id');
                    $table->dropIndex('idx_teacher_declarations_evidence_upload_id');
                    $table->dropColumn('evidence_upload_id');
                });
            }
        }

        if ($schema->hasTable('users')) {
            if (! $schema->hasColumn('users', 'avatar_url')) {
                $schema->table('users', function (Blueprint $table): void {
                    $table->string('avatar_url', 500)->nullable();
                });
            }

            if ($schema->hasColumn('users', 'avatar_upload_id')) {
                $schema->table('users', function (Blueprint $table): void {
                    $table->dropForeign('fk_users_avatar_upload_id');
                    $table->dropIndex('idx_users_avatar_upload_id');
                    $table->dropColumn('avatar_upload_id');
                });
            }
        }

        if ($schema->hasTable('schools')) {
            if (! $schema->hasColumn('schools', 'logo_url')) {
                $schema->table('schools', function (Blueprint $table): void {
                    $table->string('logo_url', 500)->nullable();
                });
            }

            if ($schema->hasColumn('schools', 'logo_upload_id')) {
                $schema->table('schools', function (Blueprint $table): void {
                    $table->dropForeign('fk_schools_logo_upload_id');
                    $table->dropIndex('idx_schools_logo_upload_id');
                    $table->dropColumn('logo_upload_id');
                });
            }
        }

        $schema->dropIfExists('image_uploads');
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

    private function applyTenantRlsAndGrants(ConnectionInterface $db, string $table): void
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
