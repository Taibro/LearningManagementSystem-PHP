<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        DB::unprepared(<<<'SQL'
INSERT INTO schools (id, code, name, domain, email, subscription_status, is_active) VALUES
    (1, 'HUIT',  'Trường ĐH Công Thương TP.HCM (HUIT)',  'huit.edu.vn',  'admin@huit.edu.vn',  'ACTIVE', true),
    (2, 'HCMUT', 'Trường ĐH Bách Khoa TP.HCM (HCMUT)', 'hcmut.edu.vn', 'admin@hcmut.edu.vn', 'ACTIVE', true)
ON CONFLICT (code) DO NOTHING;

SELECT setval(pg_get_serial_sequence('schools', 'id'), GREATEST((SELECT COALESCE(MAX(id), 1) FROM schools), 2));

INSERT INTO saas_plans (code, name, description, monthly_price, yearly_price, max_students, max_teachers, max_storage_gb) VALUES
    ('STARTER',    'Starter Plan',    'Basic LMS plan for small centers',       2000000.00,  20000000.00, 1000,  50,  20),
    ('PRO',        'Professional',    'Standard plan for colleges/faculties',   5000000.00,  50000000.00, 5000,  200, 100),
    ('ENTERPRISE', 'Enterprise Plan', 'Full multi-campus university LMS suite', 15000000.00, 150000000.00, 50000, 2000, 1000)
ON CONFLICT (code) DO NOTHING;

INSERT INTO departments (school_id, code, name, description, is_active) VALUES
    (1, 'FIT', 'Khoa Công nghệ Thông tin', 'Faculty of Information Technology - HUIT', true),
    (2, 'CSE', 'Khoa Khoa học và Kỹ thuật Máy tính', 'Computer Science & Engineering - HCMUT', true)
ON CONFLICT (school_id, code) DO NOTHING;

INSERT INTO users (school_id, email, full_name, is_active, is_verified) VALUES
    (1, 'superadmin@edusaas.io', 'Super Admin',       true, true),
    (1, 'admin@huit.edu.vn',     'Quản Trị HUIT',     true, true),
    (2, 'admin@hcmut.edu.vn',    'Quản Trị HCMUT',    true, true),
    (1, 'nguyenvana@huit.edu.vn','Nguyễn Văn A',      true, true),
    (1, 'ntai8448@gmail.com',    'Nguyễn Thành Tài',  true, true)
ON CONFLICT (school_id, email) DO NOTHING;

INSERT INTO user_roles (school_id, user_id, role_id, is_active)
SELECT u.school_id, u.id, r.id, true
FROM users u
JOIN role r ON (
    (u.email = 'superadmin@edusaas.io'  AND r.name = 'SAAS_ADMIN') OR
    (u.email = 'admin@huit.edu.vn'      AND r.name = 'SCHOOL_ADMIN') OR
    (u.email = 'admin@hcmut.edu.vn'     AND r.name = 'SCHOOL_ADMIN') OR
    (u.email = 'nguyenvana@huit.edu.vn' AND r.name = 'LECTURER') OR
    (u.email = 'ntai8448@gmail.com'     AND r.name = 'STUDENT')
)
WHERE NOT EXISTS (
    SELECT 1 FROM user_roles ur WHERE ur.school_id = u.school_id AND ur.user_id = u.id AND ur.role_id = r.id
);

INSERT INTO teachers (school_id, user_id, department_id, teacher_code, specialization, qualification, status)
SELECT 1, u.id, d.id, 'GV001', 'Công nghệ phần mềm', 'Thạc sĩ', 'ACTIVE'
FROM users u
LEFT JOIN departments d ON d.school_id = 1 AND d.code = 'FIT'
WHERE u.school_id = 1 AND u.email = 'nguyenvana@huit.edu.vn'
ON CONFLICT (school_id, teacher_code) DO NOTHING;

INSERT INTO students (school_id, user_id, department_id, student_code, Major, DegreeLevel, TrainingType, AdministrativeClass, enrollment_status)
SELECT 1, u.id, d.id, '2001230773', 'Công nghệ thông tin', 'Đại học', 'Chính quy', '14DHTH01', 'ENROLLED'
FROM users u
LEFT JOIN departments d ON d.school_id = 1 AND d.code = 'FIT'
WHERE u.school_id = 1 AND u.email = 'ntai8448@gmail.com'
ON CONFLICT (school_id, student_code) DO NOTHING;
SQL);
    }

    public function down(): void
    {
        // Keep seeded baseline tenants intact on rollback
    }
};

