# Những điểm THIẾU / SAI cần sửa:

**Vấn đề / Giải thích**

- **Chưa có ENABLE ROW LEVEL SECURITY**: File mới chỉ tạo bảng, chưa kích hoạt RLS
- **Chưa có CREATE POLICY**: Không có policy nào được định nghĩa
- **Bảng global chưa được xử lý**: role, saas_plans, salary_config, salary_grade là bảng dùng chung cho toàn hệ thống, không nên có school_id hoặc cần policy đặc biệt
- **Thiếu Role PostgreSQL**: Chưa tạo các DB role: saas_admin, school_admin, app_user
- **Bảng schools cần policy đặc biệt**: Tenant chỉ xem được chính mình, SAAS_ADMIN xem tất cả
- **Thiếu WITH CHECK cho INSERT/UPDATE**: Cần đảm bảo user không thể insert record của tenant khác
- **Bảng audit_logs, system_error_logs**: Chỉ Super Admin xem được, không áp dụng policy tenant 

---

# PHẦN 2: SCRIPT BỔ SUNG RLS HOÀN CHỈNH 

```sql
-- ============================================================
-- BƯỚC 1: TẠO CÁC DB ROLE
-- ============================================================
-- Role cho Super Admin của hệ thống SaaS (bạn - người sở hữu phần mềm)
CREATE ROLE saas_admin_role WITH LOGIN PASSWORD 'strong_password_here';

-- Role cho ứng dụng Laravel kết nối (dùng chung cho tất cả tenant)
CREATE ROLE lms_app_role WITH LOGIN PASSWORD 'another_strong_password';

-- Cấp quyền sử dụng schema
GRANT USAGE ON SCHEMA public TO lms_app_role;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO lms_app_role;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lms_app_role;

-- ============================================================
-- BƯỚC 2: KÍCH HOẠT RLS CHO TẤT CẢ BẢNG CÓ school_id
-- ============================================================

-- Danh sách các bảng cần RLS (các bảng chứa school_id)
ALTER TABLE school_branches ENABLE ROW LEVEL SECURITY;
ALTER TABLE academic_years ENABLE ROW LEVEL SECURITY;
ALTER TABLE semesters ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedule_exceptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE tuition_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE tuition_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_semester_summaries ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_declarations ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE saas_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE saas_invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_error_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_evaluations ENABLE ROW LEVEL SECURITY;
ALTER TABLE class_teacher ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_salary_sheet ENABLE ROW LEVEL SECURITY;
ALTER TABLE teacher_salary_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- BƯỚC 3: FORCE RLS CHO TABLE OWNER (Quan trọng!)
-- Mặc định, owner của bảng BYPASS RLS. Nếu app kết nối bằng owner
-- thì RLS vô tác dụng. Bắt buộc phải FORCE.
-- ============================================================
ALTER TABLE schools FORCE ROW LEVEL SECURITY;
ALTER TABLE school_branches FORCE ROW LEVEL SECURITY;
ALTER TABLE academic_years FORCE ROW LEVEL SECURITY;
ALTER TABLE semesters FORCE ROW LEVEL SECURITY;
ALTER TABLE users FORCE ROW LEVEL SECURITY;
ALTER TABLE teachers FORCE ROW LEVEL SECURITY;
ALTER TABLE students FORCE ROW LEVEL SECURITY;
ALTER TABLE courses FORCE ROW LEVEL SECURITY;
ALTER TABLE classes FORCE ROW LEVEL SECURITY;
ALTER TABLE schedules FORCE ROW LEVEL SECURITY;
ALTER TABLE enrollments FORCE ROW LEVEL SECURITY;
ALTER TABLE attendance_records FORCE ROW LEVEL SECURITY;
ALTER TABLE tuition_invoices FORCE ROW LEVEL SECURITY;
ALTER TABLE teacher_salary_sheet FORCE ROW LEVEL SECURITY;
ALTER TABLE audit_logs FORCE ROW LEVEL SECURITY;

-- ============================================================
-- BƯỚC 4: TẠO POLICY - DÙNG FUNCTION HỖ TRỢ
-- ============================================================

-- Function kiểm tra có phải SAAS_ADMIN không
CREATE OR REPLACE FUNCTION is_saas_admin() RETURNS BOOLEAN AS $$
BEGIN
    RETURN current_setting('app.current_role', true) = 'SAAS_ADMIN';
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql STABLE;

-- Function lấy school_id hiện tại từ session
CREATE OR REPLACE FUNCTION current_school_id() RETURNS INTEGER AS $$
BEGIN
    RETURN NULLIF(current_setting('app.current_school_id', true), '')::INTEGER;
EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================
-- BƯỚC 5: POLICY CHO BẢNG SCHOOLS (ĐẶC BIỆT)
-- ============================================================

-- Tenant chỉ xem được chính school của mình
CREATE POLICY schools_tenant_select ON schools
    FOR SELECT
    USING (id = current_school_id() OR is_saas_admin());

-- SAAS_ADMIN có thể tạo school mới (khi onboard khách hàng mới)
CREATE POLICY schools_saas_insert ON schools
    FOR INSERT
    WITH CHECK (is_saas_admin());

-- Tenant có thể UPDATE school của chính mình
CREATE POLICY schools_tenant_update ON schools
    FOR UPDATE
    USING (id = current_school_id() OR is_saas_admin())
    WITH CHECK (id = current_school_id());

-- ============================================================
-- BƯỚC 6: POLICY CHO CÁC BẢNG CÓ school_id (PATTERN CHUẨN)
-- Dùng function macro cho gọn
-- ============================================================

-- Áp dụng cho các bảng "bình thường" - tenant chỉ thấy data của mình
-- Policy SELECT
CREATE POLICY tenant_select_branches ON school_branches FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_years ON academic_years FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_semesters ON semesters FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_departments ON departments FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_users ON users FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_teachers ON teachers FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_students ON students FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_courses ON courses FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_rooms ON rooms FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_classes ON classes FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_schedules ON schedules FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_enrollments ON enrollments FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_attendance ON attendance_records FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_materials ON class_materials FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_evaluations ON teacher_evaluations FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY tenant_select_salary ON teacher_salary_sheet FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());

-- Policy INSERT - Không được insert record của tenant khác
CREATE POLICY tenant_insert_branches ON school_branches FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_years ON academic_years FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_semesters ON semesters FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_departments ON departments FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_users ON users FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_teachers ON teachers FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_students ON students FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_courses ON courses FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_rooms ON rooms FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_classes ON classes FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_schedules ON schedules FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_enrollments ON enrollments FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_attendance ON attendance_records FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_materials ON class_materials FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_evaluations ON teacher_evaluations FOR INSERT WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_insert_salary ON teacher_salary_sheet FOR INSERT WITH CHECK (school_id = current_school_id());

-- Policy UPDATE
CREATE POLICY tenant_update_users ON users FOR UPDATE USING (school_id = current_school_id()) WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_update_classes ON classes FOR UPDATE USING (school_id = current_school_id()) WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_update_enrollments ON enrollments FOR UPDATE USING (school_id = current_school_id()) WITH CHECK (school_id = current_school_id());
CREATE POLICY tenant_update_attendance ON attendance_records FOR UPDATE USING (school_id = current_school_id()) WITH CHECK (school_id = current_school_id());

-- ============================================================
-- BƯỚC 7: POLICY ĐẶC BIỆT CHO BẢNG GLOBAL (KHÔNG CÓ school_id)
-- ============================================================

-- Bảng role - ai cũng xem được (để hiển thị tên role)
ALTER TABLE role ENABLE ROW LEVEL SECURITY;
CREATE POLICY role_select_all ON role FOR SELECT USING (true);

-- Bảng saas_plans - ai cũng xem được (để hiển thị gói cước)
ALTER TABLE saas_plans ENABLE ROW LEVEL SECURITY;
CREATE POLICY plan_select_all ON saas_plans FOR SELECT USING (true);

-- Bảng salary_config, salary_grade - chỉ school_admin hoặc saas_admin xem
ALTER TABLE salary_config ENABLE ROW LEVEL SECURITY;
CREATE POLICY salary_config_select ON salary_config FOR SELECT USING (is_saas_admin());

ALTER TABLE salary_grade ENABLE ROW LEVEL SECURITY;
CREATE POLICY salary_grade_select ON salary_grade FOR SELECT USING (is_saas_admin());

-- ============================================================
-- BƯỚC 8: AUDIT LOGS - CHỈ SUPER ADMIN XEM ĐƯỢC
-- ============================================================
CREATE POLICY audit_logs_saas_only ON audit_logs
    FOR SELECT
    USING (is_saas_admin());

CREATE POLICY audit_logs_insert ON audit_logs
    FOR INSERT
    WITH CHECK (school_id = current_school_id() OR is_saas_admin());

-- ============================================================
-- BƯỚC 9: SYSTEM ERROR LOGS - CHỈ SUPER ADMIN
-- ============================================================
CREATE POLICY error_logs_saas_only ON system_error_logs
    FOR SELECT
    USING (is_saas_admin());

-- ============================================================
-- BƯỚC 10: SAAS SUBSCRIPTIONS & INVOICES
-- Tenant xem được subscription của chính mình
-- ============================================================
CREATE POLICY sub_tenant_select ON saas_subscriptions FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());
CREATE POLICY sinv_tenant_select ON saas_invoices FOR SELECT USING (school_id = current_school_id() OR is_saas_admin());

-- ============================================================
-- CẤP QUYỀN SỬ DỤNG FUNCTIONS CHO lms_app_role
-- ============================================================
GRANT EXECUTE ON FUNCTION is_saas_admin() TO lms_app_role;
GRANT EXECUTE ON FUNCTION current_school_id() TO lms_app_role;
```

---

# PHẦN 3: KIẾN TRÚC LARAVEL VỚI POSTGRESQL RLS

Luồng hoạt động:

```text
┌─────────────┐   Login    ┌──────────────┐
│  Browser    │ ─────────> │  Laravel     │
└─────────────┘            └──────┬───────┘
                                  │
                                  ▼
                          ┌──────────────┐
                          │ Auth Guard   │
                          │ (Session)    │
                          └──────┬───────┘
                                  │
                                  ▼
                    ┌──────────────────────────┐
                    │  Middleware              │
                    │  SetTenantContext        │
                    │                          │
                    │  SET app.current_school  │
                    │  SET app.current_user    │
                    │  SET app.current_role    │
                    └──────┬───────────────────┘
                           │
                           ▼
                    ┌──────────────────┐
                    │  Controller      │
                    │  User::all()     │ <-- Không cần WHERE school_id!
                    └──────┬───────────┘
                           │
                           ▼
                    ┌──────────────────┐
                    │  PostgreSQL      │
                    │  + RLS Policies  │
                    └──────────────────┘
```

---

# PHẦN 4: CODE LARAVEL CHI TIẾT

### 4.1. Cấu hình `config/database.php`
```php
'pgsql' => [
    'driver' => 'pgsql',
    'url' => env('DATABASE_URL'),
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '5432'),
    'database' => env('DB_DATABASE', 'quan_ly_lop_hoc'),
    'username' => env('DB_USERNAME', 'lms_app_role'), // ⚠️ Dùng app role, KHÔNG dùng owner
    'password' => env('DB_PASSWORD', ''),
    'charset' => 'utf8',
    'prefix' => '',
    'prefix_indexes' => true,
    'search_path' => 'public',
    'sslmode' => 'prefer',
    'options' => [
        // QUAN TRỌNG: Disable prepared statements nếu dùng PgBouncer transaction mode
        PDO::ATTR_EMULATE_PREPARES => true,
    ],
],
```

### 4.2. Service thiết lập context
Tạo file `app/Services/PostgresContextService.php`:
```php
<?php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use App\Models\User;

class PostgresContextService
{
    /**
     * Thiết lập context cho session PostgreSQL hiện tại
     * Phải gọi SAU khi có kết nối và TRƯỚC khi query bất kỳ bảng nào có RLS
     */
    public static function setContext(?User $user): void
    {
        if (!$user) {
            // Reset context cho guest
            self::clearContext();
            return;
        }

        $schoolId = $user->school_id ?? 0;
        $userId   = $user->id;
        $role     = $user->getRoleName(); // Helper method

        // Dùng SET LOCAL để chỉ áp dụng trong transaction hiện tại
        // Hoặc SET để áp dụng cho cả connection
        DB::unprepared("SET app.current_school_id = '{$schoolId}'");
        DB::unprepared("SET app.current_user_id = '{$userId}'");
        DB::unprepared("SET app.current_role = '{$role}'");
    }

    public static function clearContext(): void
    {
        DB::unprepared("RESET app.current_school_id");
        DB::unprepared("RESET app.current_user_id");
        DB::unprepared("RESET app.current_role");
    }

    /**
     * Dùng cho các tác vụ background (cron, queue) cần chạy multi-tenant
     */
    public static function runAsSchool(int $schoolId, string $role, callable $callback)
    {
        $previousSchool = DB::selectOne("SELECT current_setting('app.current_school_id', true) as val")->val ?? null;
        
        try {
            DB::unprepared("SET app.current_school_id = '{$schoolId}'");
            DB::unprepared("SET app.current_role = '{$role}'");
            return $callback();
        } finally {
            if ($previousSchool) {
                DB::unprepared("SET app.current_school_id = '{$previousSchool}'");
            } else {
                DB::unprepared("RESET app.current_school_id");
            }
        }
    }
}
```

### 4.3. Middleware tự động set context
Tạo `app/Http/Middleware/SetTenantContext.php`:
```php
<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Services\PostgresContextService;

class SetTenantContext
{
    public function handle(Request $request, Closure $next)
    {
        // Chỉ set context khi đã đăng nhập
        if (Auth::check()) {
            PostgresContextService::setContext(Auth::user());
        } else {
            PostgresContextService::clearContext();
        }

        return $next($request);
    }
}
```
Đăng ký trong `bootstrap/app.php` (Laravel 11) hoặc `app/Http/Kernel.php`:
```php
// Laravel 11 - bootstrap/app.php
->withMiddleware(function (Middleware $middleware) {
    $middleware->append(\App\Http\Middleware\SetTenantContext::class);
})
```

### 4.4. Helper method trong User Model
Trong `app/Models/User.php`:
```php
<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;

class User extends Authenticatable
{
    // ...

    /**
     * Lấy tên role cao nhất của user để set vào Postgres
     */
    public function getRoleName(): string
    {
        // Ưu tiên theo thứ tự
        if ($this->hasRole('SAAS_ADMIN'))   return 'SAAS_ADMIN';
        if ($this->hasRole('SCHOOL_ADMIN')) return 'SCHOOL_ADMIN';
        if ($this->hasRole('LECTURER'))     return 'LECTURER';
        if ($this->hasRole('STUDENT'))      return 'STUDENT';
        
        return 'GUEST';
    }

    public function hasRole(string $roleName): bool
    {
        return $this->roles()->where('name', $roleName)->exists();
    }
}
```

### 4.5. AuthController - Login Flow hoàn chỉnh
```php
<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\PostgresContextService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    public function login(Request $request)
    {
        $credentials = $request->validate([
            'email'    => 'required|email',
            'password' => 'required',
        ]);

        // ⚠️ QUAN TRỌNG: Khi đăng nhập, ta CHƯA có context, nên phải query bằng owner connection
        // Tạo connection riêng để bypass RLS khi xác thực
        $user = User::on('pgsql_owner')
            ->with('roles')
            ->where('email', $credentials['email'])
            ->first();

        if (!$user || !Hash::check($credentials['password'])) {
            throw ValidationException::withMessages([
                'email' => ['Thông tin đăng nhập không chính xác.'],
            ]);
        }

        if (!$user->is_active) {
            throw ValidationException::withMessages([
                'email' => ['Tài khoản đã bị khóa.'],
            ]);
        }

        // Đăng nhập
        Auth::login($user, $request->boolean('remember'));
        $request->session()->regenerate();

        // Set context ngay sau khi login
        PostgresContextService::setContext($user);

        // Cập nhật last_login (cần connection owner nếu user chưa có context)
        $user->update(['last_login_at' => now()]);

        return response()->json([
            'message' => 'Đăng nhập thành công',
            'user' => [
                'id' => $user->id,
                'full_name' => $user->full_name,
                'email' => $user->email,
                'school_id' => $user->school_id,
                'role' => $user->getRoleName(),
            ],
        ]);
    }

    public function logout(Request $request)
    {
        PostgresContextService::clearContext();
        Auth::guard('web')->logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();

        return response()->json(['message' => 'Đã đăng xuất']);
    }
}
```
Thêm connection `pgsql_owner` trong `config/database.php`:
```php
'pgsql_owner' => [
    'driver' => 'pgsql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '5432'),
    'database' => env('DB_DATABASE', 'quan_ly_lop_hoc'),
    'username' => env('DB_OWNER_USERNAME', 'postgres'), // ⚠️ Dùng owner/superuser
    'password' => env('DB_OWNER_PASSWORD', ''),
    'charset' => 'utf8',
    'prefix' => '',
    'schema' => 'public',
    'sslmode' => 'prefer',
],
```

### 4.6. Ví dụ Controller sử dụng RLS
```php
<?php

namespace App\Http\Controllers;

use App\Models\Classes;
use App\Models\Enrollment;
use App\Models\User;
use Illuminate\Http\Request;

class ClassController extends Controller
{
    /**
     * Lấy danh sách lớp học - KHÔNG CẦN WHERE school_id!
     * RLS đã tự động filter
     */
    public function index()
    {
        // Query này sẽ tự động có WHERE school_id = X nhờ RLS
        $classes = Classes::with(['course', 'teacher'])
            ->where('status', 'OPEN')
            ->paginate(20);

        return response()->json($classes);
    }

    /**
     * Lấy thông tin 1 lớp - RLS đảm bảo user chỉ lấy được lớp của trường mình
     */
    public function show($id)
    {
        $class = Classes::with(['enrollments.student', 'schedules'])
            ->findOrFail($id); // Nếu class không thuộc tenant -> 404 tự động

        return response()->json($class);
    }

    /**
     * Đăng ký học - RLS WITH CHECK đảm bảo student cùng school với class
     */
    public function enroll(Request $request, $classId)
    {
        $request->validate([
            'student_id' => 'required|exists:students,id',
        ]);

        // Nếu student_id không thuộc tenant hiện tại, RLS sẽ chặn!
        $enrollment = Enrollment::create([
            'student_id' => $request->student_id,
            'class_id' => $classId,
            'status' => 'ENROLLED',
            'school_id' => auth()->user()->school_id, // Vẫn nên set để tường minh
        ]);

        return response()->json($enrollment, 201);
    }
}
```

### 4.7. Queue Job với Multi-tenant
```php
<?php

namespace App\Jobs;

use App\Models\School;
use App\Models\User;
use App\Services\PostgresContextService;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class SendMonthlyReportEmail implements ShouldQueue
{
    use InteractsWithQueue, Queueable, SerializesModels;

    public function __construct(public int $schoolId)
    {
    }

    public function handle(): void
    {
        // Wrap trong context của tenant cụ thể
        PostgresContextService::runAsSchool($this->schoolId, 'SCHOOL_ADMIN', function () {
            $school = School::findOrFail($this->schoolId);
            
            // Query tự động filter theo school_id
            $totalStudents = User::whereHas('roles', fn($q) => $q->where('name', 'STUDENT'))->count();
            $totalClasses = \App\Models\Classes::where('status', 'IN_PROGRESS')->count();
            
            // Gửi email...
            \Mail::to($school->email)->send(new MonthlyReport($school, $totalStudents, $totalClasses));
        });
    }
}
```

---

# PHẦN 5: KIỂM TRA & TEST RLS

Test thủ công bằng `psql`:
```sql
-- Kết nối bằng app role
psql -U lms_app_role -d quan_ly_lop_hoc

-- Thử query TRƯỚC khi set context -> Sẽ KHÔNG thấy gì
SELECT id, code, name FROM schools;
-- Kết quả: 0 rows (RLS chặn)

-- Set context cho school_id = 1
SET app.current_school_id = '1';
SET app.current_role = 'SCHOOL_ADMIN';

-- Query lại -> Chỉ thấy school có id = 1
SELECT id, code, name FROM schools;
-- Kết quả: 1 row

-- Thử insert record của school khác -> BỊ CHẶN
INSERT INTO school_branches (school_id, code, name, address, city, is_main, is_active, created_at, updated_at)
VALUES (999, 'CS1', 'Branch fake', '123 St', 'HCM', true, true, now(), now());
-- LỖI: new row violates row-level security policy

-- Set context SAAS_ADMIN -> thấy TẤT CẢ
SET app.current_role = 'SAAS_ADMIN';
SELECT id, code, name FROM schools;
-- Kết quả: tất cả schools
```

Test trong Laravel (Tinker):
```php
// Login với user của school 1
Auth::login(User::find(1));
\App\Services\PostgresContextService::setContext(Auth::user());

// Query - chỉ thấy data của school 1
\App\Models\Classes::count(); // VD: 15

// Thử "hack" - lấy class của school khác
\DB::statement("SET app.current_school_id = '2'");
\App\Models\Classes::count(); // Nếu user không phải SAAS_ADMIN, vẫn chỉ thấy 15 (RLS chặn)
```

---

# NHỮNG ĐIỂM CẦN ĐẶC BIỆT LƯU Ý

1. **Connection Pooling (PgBouncer, Supabase, RDS Proxy)**
Nếu dùng pooler ở transaction mode, lệnh SET có thể bị mất sau mỗi transaction. Giải pháp:
- Dùng `SET LOCAL` thay vì `SET`
- Hoặc set context trong mỗi transaction:
```php
DB::transaction(function () {
    DB::unprepared("SET LOCAL app.current_school_id = '{$schoolId}'");
    // các query ở đây
});
```

2. **Queue Workers (Supervisor)**
Mỗi worker giữ connection lâu dài, phải đảm bảo context được reset giữa các job:
```php
// Trong AppServiceProvider
Queue::before(function (JobProcessing $event) {
    PostgresContextService::clearContext();
});

Queue::after(function (JobProcessing $event) {
    PostgresContextService::clearContext();
});
```

3. **Foreign Key Validation với RLS**
Khi insert enrollment với `student_id` không hợp lệ, Postgres sẽ báo FK violation vì RLS chặn không cho "nhìn thấy" student đó. Đây là hành vi đúng và an toàn. 

4. **Migration với RLS**
Khi chạy `php artisan migrate`, dùng connection owner (superuser) để BYPASS RLS:
```php
// DatabaseServiceProvider
public function boot()
{
    if (app()->runningInConsole()) {
        // CLI (migrate) dùng owner connection
        config(['database.default' => 'pgsql_owner']);
    }
}
```
