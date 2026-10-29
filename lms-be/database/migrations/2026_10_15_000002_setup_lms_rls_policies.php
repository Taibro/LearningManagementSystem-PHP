<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\File;

return new class extends Migration
{
    public function up(): void
    {
        $sqlPath = database_path('sql/02_lms_rls_policies.sql');
        if (! File::exists($sqlPath)) {
            throw new RuntimeException("Không tìm thấy file RLS SQL tại: {$sqlPath}");
        }

        DB::unprepared(File::get($sqlPath));
    }

    public function down(): void
    {
        DB::statement('DROP FUNCTION IF EXISTS is_saas_admin() CASCADE;');
        DB::statement('DROP FUNCTION IF EXISTS current_app_role() CASCADE;');
        DB::statement('DROP FUNCTION IF EXISTS current_app_user_id() CASCADE;');
        DB::statement('DROP FUNCTION IF EXISTS current_school_id() CASCADE;');
    }
};

