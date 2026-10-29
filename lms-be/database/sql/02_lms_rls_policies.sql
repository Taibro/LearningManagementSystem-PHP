-- ============================================================================
-- FILE: database/sql/02_lms_rls_policies.sql
-- DATABASE ROLES & ROW-LEVEL SECURITY (RLS) SETUP FOR MULTI-TENANT LMS
-- ============================================================================

-- 1. CREATE APPLICATION ROLE (NO BYPASSRLS) & SAAS ADMIN ROLE
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'lms_app_role') THEN
        CREATE ROLE lms_app_role WITH LOGIN PASSWORD 'lms_app_secret_password' NOBYPASSRLS NOSUPERUSER NOCREATEDB NOCREATEROLE;
    END IF;

    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'saas_admin_role') THEN
        CREATE ROLE saas_admin_role WITH LOGIN PASSWORD 'saas_admin_secret_password' BYPASSRLS;
    END IF;
END
$$;

-- Grant CRUD permissions on public schema tables and sequences to both roles
GRANT USAGE ON SCHEMA public TO lms_app_role, saas_admin_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO lms_app_role, saas_admin_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lms_app_role, saas_admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO lms_app_role, saas_admin_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT USAGE, SELECT ON SEQUENCES TO lms_app_role, saas_admin_role;

-- 2. HELPER FUNCTIONS TO READ CONTEXT FROM POSTGRESQL SESSION
CREATE OR REPLACE FUNCTION current_school_id() RETURNS INTEGER AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_school_id', true), '')::INTEGER;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION current_app_user_id() RETURNS INTEGER AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_user_id', true), '')::INTEGER;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION current_app_role() RETURNS TEXT AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_role', true), '');
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION is_saas_admin() RETURNS BOOLEAN AS $$
BEGIN
    RETURN current_setting('app.current_role', true) = 'SAAS_ADMIN';
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql STABLE;

GRANT EXECUTE ON FUNCTION current_school_id()   TO lms_app_role, saas_admin_role;
GRANT EXECUTE ON FUNCTION current_app_user_id() TO lms_app_role, saas_admin_role;
GRANT EXECUTE ON FUNCTION current_app_role()    TO lms_app_role, saas_admin_role;
GRANT EXECUTE ON FUNCTION is_saas_admin()       TO lms_app_role, saas_admin_role;

-- 3. ENABLE & FORCE RLS AUTOMATICALLY FOR ALL 25 TENANT TABLES CONTAINING school_id
DO $$
DECLARE
    tbl TEXT;
    tenant_tables TEXT[] := ARRAY[
        'school_branches', 'academic_years', 'semesters', 'departments',
        'users', 'user_roles', 'teachers', 'students', 'courses', 'rooms',
        'classes', 'schedules', 'schedule_exceptions', 'enrollments',
        'attendance_records', 'notifications', 'tuition_invoices',
        'tuition_payments', 'student_semester_summaries',
        'teacher_declarations', 'class_materials', 'teacher_evaluations',
        'class_teacher', 'teacher_salary_sheet', 'teacher_salary_detail'
    ];
BEGIN
    FOREACH tbl IN ARRAY tenant_tables
    LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY;', tbl);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY;', tbl);

        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_select ON %I;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_insert ON %I;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_update ON %I;', tbl);
        EXECUTE format('DROP POLICY IF EXISTS tenant_isolation_delete ON %I;', tbl);

        EXECUTE format(
            'CREATE POLICY tenant_isolation_select ON %I FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());',
            tbl
        );
        EXECUTE format(
            'CREATE POLICY tenant_isolation_insert ON %I FOR INSERT WITH CHECK (school_id = current_school_id() OR is_saas_admin());',
            tbl
        );
        EXECUTE format(
            'CREATE POLICY tenant_isolation_update ON %I FOR UPDATE USING (school_id = current_school_id() OR is_saas_admin()) WITH CHECK (school_id = current_school_id() OR is_saas_admin());',
            tbl
        );
        EXECUTE format(
            'CREATE POLICY tenant_isolation_delete ON %I FOR DELETE USING (school_id = current_school_id() OR is_saas_admin());',
            tbl
        );
    END LOOP;
END
$$;

-- 4. SPECIAL POLICIES FOR schools TABLE, SAAS TABLES & GLOBAL TABLES
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools FORCE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS schools_select_policy ON schools;
CREATE POLICY schools_select_policy ON schools FOR SELECT
    USING (id = current_school_id() OR is_saas_admin() OR is_active = true);

DROP POLICY IF EXISTS schools_insert_policy ON schools;
CREATE POLICY schools_insert_policy ON schools FOR INSERT
    WITH CHECK (is_saas_admin());

DROP POLICY IF EXISTS schools_update_policy ON schools;
CREATE POLICY schools_update_policy ON schools FOR UPDATE
    USING (id = current_school_id() OR is_saas_admin())
    WITH CHECK (id = current_school_id() OR is_saas_admin());

DROP POLICY IF EXISTS schools_delete_policy ON schools;
CREATE POLICY schools_delete_policy ON schools FOR DELETE
    USING (is_saas_admin());

-- Tables saas_subscriptions & saas_invoices
ALTER TABLE saas_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE saas_subscriptions FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS sub_select ON saas_subscriptions;
DROP POLICY IF EXISTS sub_modify ON saas_subscriptions;
CREATE POLICY sub_select ON saas_subscriptions FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY sub_modify ON saas_subscriptions FOR ALL USING (is_saas_admin()) WITH CHECK (is_saas_admin());

ALTER TABLE saas_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE saas_invoices FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS sinv_select ON saas_invoices;
DROP POLICY IF EXISTS sinv_modify ON saas_invoices;
CREATE POLICY sinv_select ON saas_invoices FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY sinv_modify ON saas_invoices FOR ALL USING (is_saas_admin()) WITH CHECK (is_saas_admin());

-- Tables audit_logs & system_error_logs
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS audit_select ON audit_logs;
DROP POLICY IF EXISTS audit_insert ON audit_logs;
CREATE POLICY audit_select ON audit_logs FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY audit_insert ON audit_logs FOR INSERT WITH CHECK (school_id = current_school_id() OR is_saas_admin());

ALTER TABLE system_error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_error_logs FORCE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS err_select ON system_error_logs;
DROP POLICY IF EXISTS err_insert ON system_error_logs;
CREATE POLICY err_select ON system_error_logs FOR SELECT USING (is_saas_admin());
CREATE POLICY err_insert ON system_error_logs FOR INSERT WITH CHECK (true);

-- Global tables (role, saas_plans, salary_config, salary_grade)
ALTER TABLE role ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS role_read_all ON role;
CREATE POLICY role_read_all ON role FOR SELECT USING (true);

ALTER TABLE saas_plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS plans_read_all ON saas_plans;
DROP POLICY IF EXISTS plans_write_saas ON saas_plans;
CREATE POLICY plans_read_all ON saas_plans FOR SELECT USING (true);
CREATE POLICY plans_write_saas ON saas_plans FOR ALL USING (is_saas_admin()) WITH CHECK (is_saas_admin());

ALTER TABLE salary_config ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS sal_cfg_read_all ON salary_config;
CREATE POLICY sal_cfg_read_all ON salary_config FOR SELECT USING (true);

ALTER TABLE salary_grade ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS sal_grd_read_all ON salary_grade;
CREATE POLICY sal_grd_read_all ON salary_grade FOR SELECT USING (true);
