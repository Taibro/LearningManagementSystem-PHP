-- ============================================================
-- FILE: database/sql/01_lms_schema.sql
-- MULTI-TENANT LEARNING MANAGEMENT SYSTEM (LMS)
-- PostgreSQL 16 Standard - Circular foreign keys resolved
-- UUID (gen_random_uuid) integrated for all tables
-- ============================================================

-- Enable pgcrypto extension (supports gen_random_uuid across all PostgreSQL versions)
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. SCHOOLS TABLE (ROOT TENANT)
CREATE TABLE IF NOT EXISTS schools (
    id           SERIAL PRIMARY KEY,
    school_id    UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    code         VARCHAR(50)  NOT NULL UNIQUE,
    name         VARCHAR(255) NOT NULL,
    domain       VARCHAR(255) UNIQUE,
    address      VARCHAR(500),
    phone        VARCHAR(20),
    email        VARCHAR(255),
    logo_url     VARCHAR(500),
    subscription_status VARCHAR(20) NOT NULL DEFAULT 'TRIAL'
                 CHECK (subscription_status IN ('TRIAL', 'ACTIVE', 'EXPIRED', 'SUSPENDED')),
    is_active    BOOLEAN      NOT NULL DEFAULT true,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by   INTEGER,
    updated_by   INTEGER
);

-- 2. SCHOOL_BRANCHES TABLE (CAMPUSES / BRANCHES)
CREATE TABLE IF NOT EXISTS school_branches (
    id                 SERIAL PRIMARY KEY,
    school_branches_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id          INTEGER      NOT NULL,
    code               VARCHAR(20)  NOT NULL,
    name               VARCHAR(255) NOT NULL,
    address            VARCHAR(500),
    phone              VARCHAR(20),
    is_active          BOOLEAN      NOT NULL DEFAULT true,
    created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by         INTEGER,
    updated_by         INTEGER,
    CONSTRAINT uq_branch_code UNIQUE (school_id, code),
    CONSTRAINT fk_branch_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
);

-- 3. ACADEMIC_YEARS TABLE
CREATE TABLE IF NOT EXISTS academic_years (
    id                SERIAL PRIMARY KEY,
    academic_years_id UUID        DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id         INTEGER     NOT NULL,
    name              VARCHAR(20) NOT NULL,
    start_date        DATE        NOT NULL,
    end_date          DATE        NOT NULL,
    is_current        BOOLEAN     NOT NULL DEFAULT false,
    created_at        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by        INTEGER,
    updated_by        INTEGER,
    CONSTRAINT uq_ay_name   UNIQUE (school_id, name),
    CONSTRAINT chk_ay_dates CHECK  (end_date > start_date),
    CONSTRAINT fk_ay_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
);

-- 4. SEMESTERS TABLE
CREATE TABLE IF NOT EXISTS semesters (
    id               SERIAL PRIMARY KEY,
    semesters_id     UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id        INTEGER      NOT NULL,
    academic_year_id INTEGER      NOT NULL,
    code             VARCHAR(20)  NOT NULL,
    name             VARCHAR(100) NOT NULL,
    start_date       DATE         NOT NULL,
    end_date         DATE         NOT NULL,
    is_current       BOOLEAN      NOT NULL DEFAULT false,
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       INTEGER,
    updated_by       INTEGER,
    CONSTRAINT uq_sem_code   UNIQUE (school_id, code),
    CONSTRAINT chk_sem_dates CHECK  (end_date > start_date),
    CONSTRAINT fk_sem_school FOREIGN KEY (school_id)        REFERENCES schools(id)        ON DELETE CASCADE,
    CONSTRAINT fk_sem_ay     FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT
);

-- 5. DEPARTMENTS TABLE (FACULTIES / DEPARTMENTS)
CREATE TABLE IF NOT EXISTS departments (
    id             SERIAL PRIMARY KEY,
    departments_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id      INTEGER      NOT NULL,
    code           VARCHAR(20)  NOT NULL,
    name           VARCHAR(255) NOT NULL,
    description    TEXT,
    is_active      BOOLEAN      NOT NULL DEFAULT true,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by     INTEGER,
    updated_by     INTEGER,
    CONSTRAINT uq_dept_code   UNIQUE (school_id, code),
    CONSTRAINT fk_dept_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE
);

-- 6. ROLE TABLE (SYSTEM ROLES)
CREATE TABLE IF NOT EXISTS role (
    id             SERIAL PRIMARY KEY,
    role_id        UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    name           VARCHAR(50)  NOT NULL UNIQUE,
    description    VARCHAR(255),
    is_system_role BOOLEAN      NOT NULL DEFAULT false,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by     INTEGER,
    updated_by     INTEGER
);

INSERT INTO role (name, description, is_system_role) VALUES
    ('SAAS_ADMIN',         'Super Administrator for entire SaaS platform', true),
    ('SCHOOL_ADMIN',       'School Administrator',                          false),
    ('DEAN_OF_FACULTY',    'Dean of Faculty',                              false),
    ('DEAN_OF_DEPARTMENT', 'Head of Department',                           false),
    ('LECTURER',           'Lecturer / Teacher',                           false),
    ('STUDENT',            'Student',                                      false),
    ('GUEST',              'Guest',                                        false)
ON CONFLICT (name) DO NOTHING;

-- 7. USERS TABLE (USER ACCOUNTS - KEYCLOAK INTEGRATION)
CREATE TABLE IF NOT EXISTS users (
    id            SERIAL PRIMARY KEY,
    users_id      UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id     INTEGER      NOT NULL,
    keycloak_id   UUID         UNIQUE,
    email         VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255),
    full_name     VARCHAR(255) NOT NULL,
    phone         VARCHAR(20),
    avatar_url    VARCHAR(500),
    is_active     BOOLEAN      NOT NULL DEFAULT true,
    is_verified   BOOLEAN      NOT NULL DEFAULT false,
    last_login_at TIMESTAMP,
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by    INTEGER,
    updated_by    INTEGER,
    CONSTRAINT uq_user_email  UNIQUE (school_id, email),
    CONSTRAINT fk_user_school FOREIGN KEY (school_id)  REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_user_cby    FOREIGN KEY (created_by) REFERENCES users(id)   ON DELETE SET NULL,
    CONSTRAINT fk_user_uby    FOREIGN KEY (updated_by) REFERENCES users(id)   ON DELETE SET NULL
);

-- Add audit foreign key constraints for tables created before users table
ALTER TABLE schools         ADD CONSTRAINT fk_sch_cby    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE schools         ADD CONSTRAINT fk_sch_uby    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE school_branches ADD CONSTRAINT fk_branch_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE school_branches ADD CONSTRAINT fk_branch_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE academic_years  ADD CONSTRAINT fk_ay_cby     FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE academic_years  ADD CONSTRAINT fk_ay_uby     FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE semesters       ADD CONSTRAINT fk_sem_cby    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE semesters       ADD CONSTRAINT fk_sem_uby    FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE departments     ADD CONSTRAINT fk_dept_cby   FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL;
ALTER TABLE departments     ADD CONSTRAINT fk_dept_uby   FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL;

-- 8. USER_ROLES TABLE (USER ROLE ASSIGNMENTS)
CREATE TABLE IF NOT EXISTS user_roles (
    id            SERIAL PRIMARY KEY,
    user_roles_id UUID      DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id     INTEGER   NOT NULL,
    user_id       INTEGER   NOT NULL,
    role_id       INTEGER   NOT NULL,
    department_id INTEGER,
    granted_by    INTEGER,
    granted_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at    TIMESTAMP,
    is_active     BOOLEAN   NOT NULL DEFAULT true,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by    INTEGER,
    updated_by    INTEGER,
    CONSTRAINT uq_user_role  UNIQUE (school_id, user_id, role_id, department_id),
    CONSTRAINT fk_ur_school  FOREIGN KEY (school_id)     REFERENCES schools(id)     ON DELETE CASCADE,
    CONSTRAINT fk_ur_user    FOREIGN KEY (user_id)       REFERENCES users(id)       ON DELETE CASCADE,
    CONSTRAINT fk_ur_role    FOREIGN KEY (role_id)       REFERENCES role(id)        ON DELETE RESTRICT,
    CONSTRAINT fk_ur_dept    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    CONSTRAINT fk_ur_grant   FOREIGN KEY (granted_by)    REFERENCES users(id)       ON DELETE SET NULL,
    CONSTRAINT fk_ur_cby     FOREIGN KEY (created_by)    REFERENCES users(id)       ON DELETE SET NULL,
    CONSTRAINT fk_ur_uby     FOREIGN KEY (updated_by)    REFERENCES users(id)       ON DELETE SET NULL
);

-- 9. TEACHERS TABLE (LECTURER PROFILES)
CREATE TABLE IF NOT EXISTS teachers (
    id             SERIAL PRIMARY KEY,
    teachers_id    UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id      INTEGER      NOT NULL,
    user_id        INTEGER      NOT NULL UNIQUE,
    department_id  INTEGER,
    teacher_code   VARCHAR(30)  NOT NULL,
    specialization VARCHAR(255),
    qualification  VARCHAR(255),
    hire_date      DATE,
    status         VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE'
                   CHECK (status IN ('ACTIVE', 'ON_LEAVE', 'RESIGNED')),
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by     INTEGER,
    updated_by     INTEGER,
    CONSTRAINT uq_teacher_code UNIQUE (school_id, teacher_code),
    CONSTRAINT fk_tc_school    FOREIGN KEY (school_id)     REFERENCES schools(id)     ON DELETE CASCADE,
    CONSTRAINT fk_tc_user      FOREIGN KEY (user_id)       REFERENCES users(id)       ON DELETE CASCADE,
    CONSTRAINT fk_tc_dept      FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    CONSTRAINT fk_tc_cby       FOREIGN KEY (created_by)    REFERENCES users(id)       ON DELETE SET NULL,
    CONSTRAINT fk_tc_uby       FOREIGN KEY (updated_by)    REFERENCES users(id)       ON DELETE SET NULL
);

-- 10. STUDENTS TABLE (STUDENT PROFILES)
CREATE TABLE IF NOT EXISTS students (
    id                  SERIAL PRIMARY KEY,
    students_id         UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id           INTEGER      NOT NULL,
    user_id             INTEGER      NOT NULL UNIQUE,
    department_id       INTEGER,
    student_code        VARCHAR(30)  NOT NULL,
    date_of_birth       DATE,
    gender              VARCHAR(10)  CHECK (gender IN ('MALE', 'FEMALE', 'OTHER')),
    address             VARCHAR(500),
    enrollment_date     DATE,
    PlaceOfBirth        VARCHAR(100),
    Population          VARCHAR(100),
    Major               VARCHAR(100),
    DegreeLevel         VARCHAR(50),
    TrainingType        VARCHAR(50),
    AdministrativeClass VARCHAR(50),
    enrollment_status   VARCHAR(20)  NOT NULL DEFAULT 'ENROLLED'
                        CHECK (enrollment_status IN ('ENROLLED', 'SUSPENDED', 'GRADUATED', 'DROPPED')),
    created_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by          INTEGER,
    updated_by          INTEGER,
    CONSTRAINT uq_student_code UNIQUE (school_id, student_code),
    CONSTRAINT fk_st_school    FOREIGN KEY (school_id)     REFERENCES schools(id)     ON DELETE CASCADE,
    CONSTRAINT fk_st_user      FOREIGN KEY (user_id)       REFERENCES users(id)       ON DELETE CASCADE,
    CONSTRAINT fk_st_dept      FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    CONSTRAINT fk_st_cby       FOREIGN KEY (created_by)    REFERENCES users(id)       ON DELETE SET NULL,
    CONSTRAINT fk_st_uby       FOREIGN KEY (updated_by)    REFERENCES users(id)       ON DELETE SET NULL
);

-- 11. COURSES TABLE (SUBJECTS / COURSES)
CREATE TABLE IF NOT EXISTS courses (
    id                SERIAL PRIMARY KEY,
    courses_id        UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id         INTEGER        NOT NULL,
    department_id     INTEGER,
    code              VARCHAR(30)    NOT NULL,
    name              VARCHAR(255)   NOT NULL,
    credits           SMALLINT       NOT NULL DEFAULT 3 CHECK (credits BETWEEN 1 AND 10),
    total_periods     INTEGER        NOT NULL DEFAULT 45,
    theory_periods    INTEGER        NOT NULL DEFAULT 30,
    practice_periods  INTEGER        NOT NULL DEFAULT 15,
    price_per_credit  DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    description       TEXT,
    is_active         BOOLEAN        NOT NULL DEFAULT true,
    created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by        INTEGER,
    updated_by        INTEGER,
    CONSTRAINT uq_course_code UNIQUE (school_id, code),
    CONSTRAINT fk_crs_school  FOREIGN KEY (school_id)     REFERENCES schools(id)     ON DELETE CASCADE,
    CONSTRAINT fk_crs_dept    FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
    CONSTRAINT fk_crs_cby     FOREIGN KEY (created_by)    REFERENCES users(id)       ON DELETE SET NULL,
    CONSTRAINT fk_crs_uby     FOREIGN KEY (updated_by)    REFERENCES users(id)       ON DELETE SET NULL
);

-- 12. ROOMS TABLE (CLASSROOMS / LABS)
CREATE TABLE IF NOT EXISTS rooms (
    id          SERIAL PRIMARY KEY,
    rooms_id    UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id   INTEGER      NOT NULL,
    branch_id   INTEGER,
    code        VARCHAR(30)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    building    VARCHAR(100),
    floor       SMALLINT,
    capacity    SMALLINT     NOT NULL DEFAULT 30 CHECK (capacity > 0),
    room_type   VARCHAR(20)  NOT NULL DEFAULT 'LECTURE'
                CHECK (room_type IN ('LECTURE', 'LAB', 'HALL', 'ONLINE')),
    is_active   BOOLEAN      NOT NULL DEFAULT true,
    created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by  INTEGER,
    updated_by  INTEGER,
    CONSTRAINT uq_room_code  UNIQUE (school_id, code),
    CONSTRAINT fk_rm_school  FOREIGN KEY (school_id)  REFERENCES schools(id)         ON DELETE CASCADE,
    CONSTRAINT fk_rm_branch  FOREIGN KEY (branch_id)  REFERENCES school_branches(id) ON DELETE SET NULL,
    CONSTRAINT fk_rm_cby     FOREIGN KEY (created_by) REFERENCES users(id)           ON DELETE SET NULL,
    CONSTRAINT fk_rm_uby     FOREIGN KEY (updated_by) REFERENCES users(id)           ON DELETE SET NULL
);

-- 13. CLASSES TABLE (COURSE CLASSES / SECTIONS)
CREATE TABLE IF NOT EXISTS classes (
    id           SERIAL PRIMARY KEY,
    classes_id   UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id    INTEGER      NOT NULL,
    semester_id  INTEGER      NOT NULL,
    course_id    INTEGER      NOT NULL,
    teacher_id   INTEGER      NOT NULL,
    code         VARCHAR(30)  NOT NULL,
    name         VARCHAR(255),
    max_students SMALLINT     NOT NULL DEFAULT 40 CHECK (max_students > 0),
    status       VARCHAR(20)  NOT NULL DEFAULT 'UPCOMING'
                 CHECK (status IN ('UPCOMING', 'ONGOING', 'COMPLETED', 'CANCELLED')),
    notes        TEXT,
    created_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at   TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by   INTEGER,
    updated_by   INTEGER,
    CONSTRAINT uq_class_code UNIQUE (school_id, code),
    CONSTRAINT fk_cls_school  FOREIGN KEY (school_id)   REFERENCES schools(id)   ON DELETE CASCADE,
    CONSTRAINT fk_cls_sem     FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE RESTRICT,
    CONSTRAINT fk_cls_course  FOREIGN KEY (course_id)   REFERENCES courses(id)   ON DELETE RESTRICT,
    CONSTRAINT fk_cls_teacher FOREIGN KEY (teacher_id)  REFERENCES teachers(id)  ON DELETE RESTRICT,
    CONSTRAINT fk_cls_cby     FOREIGN KEY (created_by)  REFERENCES users(id)     ON DELETE SET NULL,
    CONSTRAINT fk_cls_uby     FOREIGN KEY (updated_by)  REFERENCES users(id)     ON DELETE SET NULL
);

-- 14. SCHEDULES TABLE (RECURRING CLASS SCHEDULES)
CREATE TABLE IF NOT EXISTS schedules (
    id             SERIAL PRIMARY KEY,
    schedules_id   UUID        DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id      INTEGER     NOT NULL,
    class_id       INTEGER     NOT NULL,
    room_id        INTEGER     NOT NULL,
    day_of_week    SMALLINT    NOT NULL CHECK (day_of_week BETWEEN 2 AND 8),
    start_period   SMALLINT    NOT NULL CHECK (start_period >= 1),
    end_period     SMALLINT    NOT NULL CHECK (end_period >= 1),
    start_time     TIME        NOT NULL,
    end_time       TIME        NOT NULL,
    effective_from DATE        NOT NULL,
    effective_to   DATE        NOT NULL,
    session_type   VARCHAR(20) NOT NULL DEFAULT 'THEORY'
                   CHECK (session_type IN ('THEORY', 'PRACTICE', 'EXAM', 'OTHER')),
    notes          VARCHAR(500),
    is_active      BOOLEAN     NOT NULL DEFAULT true,
    created_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by     INTEGER,
    updated_by     INTEGER,
    CONSTRAINT chk_sch_periods CHECK (end_period >= start_period),
    CONSTRAINT chk_sch_times   CHECK (end_time   >  start_time),
    CONSTRAINT chk_sch_dates   CHECK (effective_to >= effective_from),
    CONSTRAINT fk_schd_school  FOREIGN KEY (school_id)  REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_schd_class   FOREIGN KEY (class_id)   REFERENCES classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_schd_room    FOREIGN KEY (room_id)    REFERENCES rooms(id)   ON DELETE RESTRICT,
    CONSTRAINT fk_schd_cby     FOREIGN KEY (created_by) REFERENCES users(id)   ON DELETE SET NULL,
    CONSTRAINT fk_schd_uby     FOREIGN KEY (updated_by) REFERENCES users(id)   ON DELETE SET NULL
);

-- 15. SCHEDULE_EXCEPTIONS TABLE (SCHEDULE CHANGES / EXCEPTIONS)
CREATE TABLE IF NOT EXISTS schedule_exceptions (
    id                     SERIAL PRIMARY KEY,
    schedule_exceptions_id UUID        DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id              INTEGER     NOT NULL,
    schedule_id            INTEGER     NOT NULL,
    exception_date         DATE        NOT NULL,
    exception_type         VARCHAR(20) NOT NULL
                           CHECK (exception_type IN ('CANCELLED', 'RESCHEDULED', 'ROOM_CHANGED', 'TEACHER_CHANGED')),
    new_date               DATE,
    new_start_time         TIME,
    new_end_time           TIME,
    new_room_id            INTEGER,
    substitute_teacher_id  INTEGER,
    reason                 VARCHAR(500),
    status                 VARCHAR(20) NOT NULL DEFAULT 'PENDING'
                           CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    approved_by            INTEGER,
    approved_at            TIMESTAMP,
    created_at             TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at             TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by             INTEGER,
    updated_by             INTEGER,
    CONSTRAINT uq_sched_exc    UNIQUE (schedule_id, exception_date),
    CONSTRAINT fk_sexc_school  FOREIGN KEY (school_id)             REFERENCES schools(id)   ON DELETE CASCADE,
    CONSTRAINT fk_sexc_sched   FOREIGN KEY (schedule_id)           REFERENCES schedules(id) ON DELETE CASCADE,
    CONSTRAINT fk_sexc_room    FOREIGN KEY (new_room_id)           REFERENCES rooms(id)     ON DELETE SET NULL,
    CONSTRAINT fk_sexc_sub_tc  FOREIGN KEY (substitute_teacher_id) REFERENCES teachers(id)  ON DELETE SET NULL,
    CONSTRAINT fk_sexc_appr    FOREIGN KEY (approved_by)           REFERENCES users(id)     ON DELETE SET NULL,
    CONSTRAINT fk_sexc_cby     FOREIGN KEY (created_by)            REFERENCES users(id)     ON DELETE SET NULL,
    CONSTRAINT fk_sexc_uby     FOREIGN KEY (updated_by)            REFERENCES users(id)     ON DELETE SET NULL
);

-- 16. ENROLLMENTS TABLE (COURSE ENROLLMENT & GRADES)
CREATE TABLE IF NOT EXISTS enrollments (
    id               SERIAL PRIMARY KEY,
    enrollments_id   UUID          DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id        INTEGER       NOT NULL,
    class_id         INTEGER       NOT NULL,
    student_id       INTEGER       NOT NULL,
    enrolled_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status           VARCHAR(20)   NOT NULL DEFAULT 'ENROLLED'
                     CHECK (status IN ('ENROLLED', 'DROPPED', 'COMPLETED')),
    attendance_score DECIMAL(4, 2) CHECK (attendance_score BETWEEN 0 AND 10),
    regular_score1   DECIMAL(4, 2) CHECK (regular_score1   BETWEEN 0 AND 10),
    regular_score2   DECIMAL(4, 2) CHECK (regular_score2   BETWEEN 0 AND 10),
    regular_score3   DECIMAL(4, 2) CHECK (regular_score3   BETWEEN 0 AND 10),
    midterm_score    DECIMAL(4, 2) CHECK (midterm_score    BETWEEN 0 AND 10),
    final_score      DECIMAL(4, 2) CHECK (final_score      BETWEEN 0 AND 10),
    total_score      DECIMAL(4, 2) CHECK (total_score      BETWEEN 0 AND 10),
    grade_letter     VARCHAR(5),
    grade_point_4    DECIMAL(3, 2) CHECK (grade_point_4    BETWEEN 0 AND 4),
    is_passed        BOOLEAN,
    notes            TEXT,
    created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       INTEGER,
    updated_by       INTEGER,
    CONSTRAINT uq_enrollment  UNIQUE (class_id, student_id),
    CONSTRAINT fk_enr_school  FOREIGN KEY (school_id)  REFERENCES schools(id)  ON DELETE CASCADE,
    CONSTRAINT fk_enr_class   FOREIGN KEY (class_id)   REFERENCES classes(id)  ON DELETE CASCADE,
    CONSTRAINT fk_enr_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_enr_cby     FOREIGN KEY (created_by) REFERENCES users(id)    ON DELETE SET NULL,
    CONSTRAINT fk_enr_uby     FOREIGN KEY (updated_by) REFERENCES users(id)    ON DELETE SET NULL
);

-- 17. ATTENDANCE_RECORDS TABLE (ATTENDANCE LOGS)
CREATE TABLE IF NOT EXISTS attendance_records (
    id                    SERIAL PRIMARY KEY,
    attendance_records_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id             INTEGER      NOT NULL,
    schedule_id           INTEGER      NOT NULL,
    student_id            INTEGER      NOT NULL,
    attendance_date       DATE         NOT NULL,
    status                VARCHAR(15)  NOT NULL DEFAULT 'PRESENT'
                          CHECK (status IN ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED')),
    note                  VARCHAR(255),
    recorded_by           INTEGER,
    created_at            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by            INTEGER,
    updated_by            INTEGER,
    CONSTRAINT uq_attendance  UNIQUE (schedule_id, student_id, attendance_date),
    CONSTRAINT fk_att_school  FOREIGN KEY (school_id)   REFERENCES schools(id)   ON DELETE CASCADE,
    CONSTRAINT fk_att_sched   FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE,
    CONSTRAINT fk_att_student FOREIGN KEY (student_id)  REFERENCES students(id)  ON DELETE CASCADE,
    CONSTRAINT fk_att_recby   FOREIGN KEY (recorded_by) REFERENCES users(id)     ON DELETE SET NULL,
    CONSTRAINT fk_att_cby     FOREIGN KEY (created_by)  REFERENCES users(id)     ON DELETE SET NULL,
    CONSTRAINT fk_att_uby     FOREIGN KEY (updated_by)  REFERENCES users(id)     ON DELETE SET NULL
);

-- 18. NOTIFICATIONS TABLE (SYSTEM & USER NOTIFICATIONS)
CREATE TABLE IF NOT EXISTS notifications (
    id                SERIAL PRIMARY KEY,
    notifications_id  UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id         INTEGER      NOT NULL,
    recipient_user_id INTEGER      NOT NULL,
    title             VARCHAR(255) NOT NULL,
    message           TEXT         NOT NULL,
    notification_type VARCHAR(30)  NOT NULL DEFAULT 'GENERAL'
                      CHECK (notification_type IN ('SCHEDULE_CHANGE', 'CLASS_CANCELLED', 'ENROLLMENT', 'ATTENDANCE', 'GENERAL')),
    reference_type    VARCHAR(50),
    reference_id      INTEGER,
    is_read           BOOLEAN      NOT NULL DEFAULT false,
    read_at           TIMESTAMP,
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by        INTEGER,
    updated_by        INTEGER,
    CONSTRAINT fk_notif_school FOREIGN KEY (school_id)         REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_notif_user   FOREIGN KEY (recipient_user_id) REFERENCES users(id)   ON DELETE CASCADE,
    CONSTRAINT fk_notif_cby    FOREIGN KEY (created_by)        REFERENCES users(id)   ON DELETE SET NULL,
    CONSTRAINT fk_notif_uby    FOREIGN KEY (updated_by)        REFERENCES users(id)   ON DELETE SET NULL
);

-- 19. TUITION_INVOICES TABLE (TUITION FEE INVOICES)
CREATE TABLE IF NOT EXISTS tuition_invoices (
    id                  SERIAL PRIMARY KEY,
    tuition_invoices_id UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id           INTEGER        NOT NULL,
    student_id          INTEGER        NOT NULL,
    semester_id         INTEGER        NOT NULL,
    invoice_code        VARCHAR(50)    NOT NULL,
    total_credits       INTEGER        NOT NULL DEFAULT 0,
    total_amount        DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    paid_amount         DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    due_date            DATE           NOT NULL,
    status              VARCHAR(20)    NOT NULL DEFAULT 'UNPAID'
                        CHECK (status IN ('UNPAID', 'PARTIAL', 'PAID', 'OVERDUE', 'CANCELLED')),
    created_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by          INTEGER,
    updated_by          INTEGER,
    CONSTRAINT uq_invoice_code UNIQUE (school_id, invoice_code),
    CONSTRAINT uq_std_sem_inv  UNIQUE (student_id, semester_id),
    CONSTRAINT fk_inv_school   FOREIGN KEY (school_id)   REFERENCES schools(id)   ON DELETE CASCADE,
    CONSTRAINT fk_inv_student  FOREIGN KEY (student_id)  REFERENCES students(id)  ON DELETE CASCADE,
    CONSTRAINT fk_inv_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE RESTRICT
);

-- 20. TUITION_PAYMENTS TABLE (TUITION PAYMENT TRANSACTIONS)
CREATE TABLE IF NOT EXISTS tuition_payments (
    id                  SERIAL PRIMARY KEY,
    tuition_payments_id UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id           INTEGER        NOT NULL,
    invoice_id          INTEGER        NOT NULL,
    transaction_code    VARCHAR(100)   NOT NULL UNIQUE,
    amount_paid         DECIMAL(15, 2) NOT NULL CHECK (amount_paid > 0),
    payment_method      VARCHAR(30)    NOT NULL DEFAULT 'QR_CODE'
                        CHECK (payment_method IN ('QR_CODE', 'BANK_TRANSFER', 'CASH', 'E_WALLET')),
    payment_date        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status              VARCHAR(20)    NOT NULL DEFAULT 'SUCCESS'
                        CHECK (status IN ('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')),
    notes               VARCHAR(500),
    created_at          TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pay_school  FOREIGN KEY (school_id)  REFERENCES schools(id)          ON DELETE CASCADE,
    CONSTRAINT fk_pay_invoice FOREIGN KEY (invoice_id) REFERENCES tuition_invoices(id) ON DELETE RESTRICT
);

-- 21. STUDENT_SEMESTER_SUMMARIES TABLE (GPA, CONDUCT SCORE & SCHOLARSHIPS)
CREATE TABLE IF NOT EXISTS student_semester_summaries (
    id                            SERIAL PRIMARY KEY,
    student_semester_summaries_id UUID          DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id                     INTEGER       NOT NULL,
    student_id                    INTEGER       NOT NULL,
    semester_id                   INTEGER       NOT NULL,
    gpa_10                        DECIMAL(4, 2) CHECK (gpa_10 BETWEEN 0 AND 10),
    gpa_4                         DECIMAL(3, 2) CHECK (gpa_4  BETWEEN 0 AND 4),
    credits_earned                SMALLINT      NOT NULL DEFAULT 0,
    conduct_score                 SMALLINT      CHECK (conduct_score BETWEEN 0 AND 100),
    conduct_rank                  VARCHAR(20)   CHECK (conduct_rank IN ('XUAT_SAC', 'TOT', 'KHA', 'TRUNG_BINH', 'YEU', 'KEM')),
    academic_rank                 VARCHAR(20)   CHECK (academic_rank IN ('XUAT_SAC', 'GIOI', 'KHA', 'TRUNG_BINH', 'YEU', 'KEM')),
    is_eligible_scholarship       BOOLEAN       NOT NULL DEFAULT false,
    scholarship_type              VARCHAR(50)   DEFAULT 'NONE'
                                  CHECK (scholarship_type IN ('NONE', 'KHUYEN_KHICH', 'TOAN_PHAN', 'BAN_PHAN')),
    created_at                    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_std_sem_sum FOREIGN KEY (school_id)   REFERENCES schools(id)   ON DELETE CASCADE,
    CONSTRAINT uq_std_sem_unique UNIQUE (student_id, semester_id),
    CONSTRAINT fk_sum_student FOREIGN KEY (student_id)  REFERENCES students(id)  ON DELETE CASCADE,
    CONSTRAINT fk_sum_sem     FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE
);

-- 22. TEACHER_DECLARATIONS TABLE (TEACHING LOAD & SCIENTIFIC RESEARCH DECLARATION)
CREATE TABLE IF NOT EXISTS teacher_declarations (
    id                      SERIAL PRIMARY KEY,
    teacher_declarations_id UUID          DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id               INTEGER       NOT NULL,
    teacher_id              INTEGER       NOT NULL,
    semester_id             INTEGER       NOT NULL,
    declaration_type        VARCHAR(30)   NOT NULL
                            CHECK (declaration_type IN ('TEACHING_LOAD', 'RESEARCH', 'OTHER_DUTY')),
    title                   VARCHAR(255)  NOT NULL,
    description             TEXT,
    claimed_hours           DECIMAL(6, 2) NOT NULL CHECK (claimed_hours >= 0),
    approved_hours          DECIMAL(6, 2) CHECK (approved_hours >= 0),
    evidence_url            VARCHAR(500),
    status                  VARCHAR(20)   NOT NULL DEFAULT 'PENDING'
                            CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    approved_by             INTEGER,
    approved_at             TIMESTAMP,
    created_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_tdec_school  FOREIGN KEY (school_id)   REFERENCES schools(id)   ON DELETE CASCADE,
    CONSTRAINT fk_tdec_teacher FOREIGN KEY (teacher_id)  REFERENCES teachers(id)  ON DELETE CASCADE,
    CONSTRAINT fk_tdec_sem     FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE RESTRICT,
    CONSTRAINT fk_tdec_appr    FOREIGN KEY (approved_by) REFERENCES users(id)     ON DELETE SET NULL
);

-- 23. CLASS_MATERIALS TABLE (COURSEWARE & CLASS MATERIALS)
CREATE TABLE IF NOT EXISTS class_materials (
    id                 SERIAL PRIMARY KEY,
    class_materials_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id          INTEGER      NOT NULL,
    class_id           INTEGER      NOT NULL,
    title              VARCHAR(255) NOT NULL,
    description        TEXT,
    file_url           VARCHAR(500) NOT NULL,
    file_type          VARCHAR(50),
    file_size          INTEGER,
    uploaded_by        INTEGER      NOT NULL,
    created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_mat_school FOREIGN KEY (school_id)   REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_mat_class  FOREIGN KEY (class_id)    REFERENCES classes(id) ON DELETE CASCADE,
    CONSTRAINT fk_mat_user   FOREIGN KEY (uploaded_by) REFERENCES users(id)   ON DELETE CASCADE
);

-- 24. SAAS_PLANS TABLE (SAAS SUBSCRIPTION PLANS)
CREATE TABLE IF NOT EXISTS saas_plans (
    id             SERIAL PRIMARY KEY,
    saas_plans_id  UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    code           VARCHAR(30)    NOT NULL UNIQUE,
    name           VARCHAR(100)   NOT NULL,
    description    TEXT,
    monthly_price  DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    yearly_price   DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    max_students   INTEGER        NOT NULL DEFAULT 500,
    max_teachers   INTEGER        NOT NULL DEFAULT 50,
    max_storage_gb INTEGER        NOT NULL DEFAULT 10,
    features       JSONB,
    is_active      BOOLEAN        NOT NULL DEFAULT true,
    created_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 25. SAAS_SUBSCRIPTIONS TABLE (TENANT SUBSCRIPTION CONTRACTS)
CREATE TABLE IF NOT EXISTS saas_subscriptions (
    id                    SERIAL PRIMARY KEY,
    saas_subscriptions_id UUID        DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id             INTEGER     NOT NULL,
    plan_id               INTEGER     NOT NULL,
    billing_cycle         VARCHAR(20) NOT NULL DEFAULT 'YEARLY'
                          CHECK (billing_cycle IN ('MONTHLY', 'YEARLY')),
    start_date            DATE        NOT NULL,
    end_date              DATE        NOT NULL,
    status                VARCHAR(20) NOT NULL DEFAULT 'ACTIVE'
                          CHECK (status IN ('TRIAL', 'ACTIVE', 'PAST_DUE', 'CANCELLED', 'EXPIRED')),
    auto_renew            BOOLEAN     NOT NULL DEFAULT true,
    created_at            TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sub_school FOREIGN KEY (school_id) REFERENCES schools(id)    ON DELETE CASCADE,
    CONSTRAINT fk_sub_plan   FOREIGN KEY (plan_id)   REFERENCES saas_plans(id) ON DELETE RESTRICT
);

-- 26. SAAS_INVOICES TABLE (SAAS PLATFORM BILLING INVOICES)
CREATE TABLE IF NOT EXISTS saas_invoices (
    id               SERIAL PRIMARY KEY,
    saas_invoices_id UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id        INTEGER        NOT NULL,
    subscription_id  INTEGER        NOT NULL,
    invoice_number   VARCHAR(50)    NOT NULL UNIQUE,
    amount           DECIMAL(15, 2) NOT NULL CHECK (amount >= 0),
    billing_date     DATE           NOT NULL,
    due_date         DATE           NOT NULL,
    paid_at          TIMESTAMP,
    payment_method   VARCHAR(30)    CHECK (payment_method IN ('BANK_TRANSFER', 'CREDIT_CARD', 'GATEWAY')),
    status           VARCHAR(20)    NOT NULL DEFAULT 'UNPAID'
                     CHECK (status IN ('UNPAID', 'PAID', 'OVERDUE', 'VOID')),
    notes            VARCHAR(500),
    created_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sinv_school FOREIGN KEY (school_id)       REFERENCES schools(id)            ON DELETE CASCADE,
    CONSTRAINT fk_sinv_sub    FOREIGN KEY (subscription_id) REFERENCES saas_subscriptions(id) ON DELETE RESTRICT
);

-- 27. SYSTEM_ERROR_LOGS TABLE (APPLICATION & SYSTEM ERROR LOGS)
CREATE TABLE IF NOT EXISTS system_error_logs (
    id                   BIGSERIAL PRIMARY KEY,
    system_error_logs_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id            INTEGER,
    user_id              INTEGER,
    error_level          VARCHAR(20)  NOT NULL DEFAULT 'ERROR'
                         CHECK (error_level IN ('INFO', 'WARNING', 'ERROR', 'CRITICAL')),
    endpoint             VARCHAR(255) NOT NULL,
    request_method       VARCHAR(10)  NOT NULL,
    status_code          SMALLINT     NOT NULL,
    error_message        TEXT         NOT NULL,
    stack_trace          TEXT,
    ip_address           VARCHAR(45),
    user_agent           VARCHAR(500),
    created_at           TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_err_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL,
    CONSTRAINT fk_err_user   FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE SET NULL
);

-- 28. AUDIT_LOGS TABLE (CRITICAL ACTIVITY AUDIT TRAILS)
CREATE TABLE IF NOT EXISTS audit_logs (
    id            BIGSERIAL PRIMARY KEY,
    audit_logs_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id     INTEGER,
    user_id       INTEGER      NOT NULL,
    action        VARCHAR(50)  NOT NULL,
    entity_name   VARCHAR(50)  NOT NULL,
    entity_id     INTEGER,
    old_values    JSONB,
    new_values    JSONB,
    ip_address    VARCHAR(45),
    created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_aud_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
    CONSTRAINT fk_aud_user   FOREIGN KEY (user_id)   REFERENCES users(id)   ON DELETE CASCADE
);

-- 29. TEACHER_EVALUATIONS TABLE (STUDENT EVALUATIONS FOR LECTURERS)
CREATE TABLE IF NOT EXISTS teacher_evaluations (
    id                     SERIAL PRIMARY KEY,
    teacher_evaluations_id UUID          DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id              INTEGER       NOT NULL,
    class_id               INTEGER       NOT NULL,
    student_id             INTEGER       NOT NULL,
    criteria_1             SMALLINT      NOT NULL CHECK (criteria_1 BETWEEN 1 AND 5),
    criteria_2             SMALLINT      NOT NULL CHECK (criteria_2 BETWEEN 1 AND 5),
    criteria_3             SMALLINT      NOT NULL CHECK (criteria_3 BETWEEN 1 AND 5),
    criteria_4             SMALLINT      NOT NULL CHECK (criteria_4 BETWEEN 1 AND 5),
    criteria_5             SMALLINT      NOT NULL CHECK (criteria_5 BETWEEN 1 AND 5),
    average_rating         DECIMAL(3, 2) NOT NULL,
    comments               TEXT,
    created_at             TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_eval_std_cls FOREIGN KEY (school_id)  REFERENCES schools(id)  ON DELETE CASCADE,
    CONSTRAINT uq_eval_unique  UNIQUE (class_id, student_id),
    CONSTRAINT fk_eval_class   FOREIGN KEY (class_id)   REFERENCES classes(id)  ON DELETE CASCADE,
    CONSTRAINT fk_eval_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- 30. CLASS_TEACHER TABLE (LECTURER ASSIGNMENT FOR COURSE CLASSES)
CREATE TABLE IF NOT EXISTS class_teacher (
    id               SERIAL PRIMARY KEY,
    class_teacher_id UUID         DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id        INTEGER      NOT NULL,
    class_id         INTEGER      NOT NULL,
    teacher_id       INTEGER      NOT NULL,
    role             VARCHAR(30)  NOT NULL DEFAULT 'MAIN'
                     CHECK (role IN ('MAIN', 'ASSISTANT', 'CO_TEACHER')),
    assigned_periods INTEGER      NOT NULL DEFAULT 0 CHECK (assigned_periods >= 0),
    note             VARCHAR(255),
    created_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       INTEGER,
    updated_by       INTEGER,
    CONSTRAINT uq_class_teacher UNIQUE (class_id, teacher_id, role),
    CONSTRAINT fk_ct_school     FOREIGN KEY (school_id)  REFERENCES schools(id)  ON DELETE CASCADE,
    CONSTRAINT fk_ct_class      FOREIGN KEY (class_id)   REFERENCES classes(id)  ON DELETE CASCADE,
    CONSTRAINT fk_ct_teacher    FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
    CONSTRAINT fk_ct_cby        FOREIGN KEY (created_by) REFERENCES users(id)    ON DELETE SET NULL,
    CONSTRAINT fk_ct_uby        FOREIGN KEY (updated_by) REFERENCES users(id)    ON DELETE SET NULL
);

-- 31. SALARY_CONFIG TABLE (HOURLY TEACHING RATE CONFIGURATION)
CREATE TABLE IF NOT EXISTS salary_config (
    id                 SERIAL PRIMARY KEY,
    salary_config_id   UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    qualification_code VARCHAR(30)    NOT NULL UNIQUE,
    qualification_name VARCHAR(100)   NOT NULL,
    price_per_period   DECIMAL(12, 2) NOT NULL CHECK (price_per_period > 0),
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- 32. SALARY_GRADE TABLE (LECTURER SALARY GRADES & STEPS)
CREATE TABLE IF NOT EXISTS salary_grade (
    id                 SERIAL PRIMARY KEY,
    salary_grade_id    UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    grade_code         VARCHAR(20)    NOT NULL,
    step_number        SMALLINT       NOT NULL CHECK (step_number >= 1),
    coefficient        DECIMAL(4, 2)  NOT NULL CHECK (coefficient > 0),
    base_salary        DECIMAL(12, 2) NOT NULL DEFAULT 2340000.00,
    seniority_pct      DECIMAL(4, 2)  NOT NULL DEFAULT 0.00,
    position_allowance DECIMAL(4, 2)  NOT NULL DEFAULT 0.00,
    effective_from     DATE           NOT NULL,
    effective_to       DATE,
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_grade_step UNIQUE (grade_code, step_number, effective_from)
);

-- 33. TEACHER_SALARY_SHEET TABLE (MONTHLY TEACHER PAYROLL)
CREATE TABLE IF NOT EXISTS teacher_salary_sheet (
    id                      SERIAL PRIMARY KEY,
    teacher_salary_sheet_id UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id               INTEGER        NOT NULL,
    teacher_id              INTEGER        NOT NULL,
    semester_id             INTEGER        NOT NULL,
    month                   SMALLINT       NOT NULL CHECK (month BETWEEN 1 AND 12),
    year                    SMALLINT       NOT NULL,
    salary_grade_id         INTEGER,
    salary_config_id        INTEGER,
    coefficient_salary      DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    seniority_allowance     DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    position_allowance      DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    total_periods_taught    INTEGER        NOT NULL DEFAULT 0,
    teaching_pay            DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    research_bonus          DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    other_allowance         DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    deductions              DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    total_net_salary        DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    status                  VARCHAR(20)    NOT NULL DEFAULT 'DRAFT'
                            CHECK (status IN ('DRAFT', 'CONFIRMED', 'PAID')),
    confirmed_by            INTEGER,
    confirmed_at            TIMESTAMP,
    paid_at                 TIMESTAMP,
    notes                   TEXT,
    created_at              TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by              INTEGER,
    updated_by              INTEGER,
    CONSTRAINT uq_salary_sheet UNIQUE (teacher_id, month, year),
    CONSTRAINT fk_ss_school    FOREIGN KEY (school_id)        REFERENCES schools(id)       ON DELETE CASCADE,
    CONSTRAINT fk_ss_teacher   FOREIGN KEY (teacher_id)       REFERENCES teachers(id)      ON DELETE CASCADE,
    CONSTRAINT fk_ss_sem       FOREIGN KEY (semester_id)      REFERENCES semesters(id)     ON DELETE RESTRICT,
    CONSTRAINT fk_ss_grade     FOREIGN KEY (salary_grade_id)  REFERENCES salary_grade(id)  ON DELETE SET NULL,
    CONSTRAINT fk_ss_config    FOREIGN KEY (salary_config_id) REFERENCES salary_config(id) ON DELETE SET NULL,
    CONSTRAINT fk_ss_conf_by   FOREIGN KEY (confirmed_by)     REFERENCES users(id)         ON DELETE SET NULL,
    CONSTRAINT fk_ss_cby       FOREIGN KEY (created_by)       REFERENCES users(id)         ON DELETE SET NULL,
    CONSTRAINT fk_ss_uby       FOREIGN KEY (updated_by)       REFERENCES users(id)         ON DELETE SET NULL
);

-- 34. TEACHER_SALARY_DETAIL TABLE (TEACHING PERIOD DETAILS IN PAYROLL)
CREATE TABLE IF NOT EXISTS teacher_salary_detail (
    id                       SERIAL PRIMARY KEY,
    teacher_salary_detail_id UUID           DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id                INTEGER        NOT NULL,
    salary_sheet_id          INTEGER        NOT NULL,
    class_id                 INTEGER        NOT NULL,
    periods_assigned         INTEGER        NOT NULL DEFAULT 0,
    periods_taught           INTEGER        NOT NULL DEFAULT 0,
    periods_makeup           INTEGER        NOT NULL DEFAULT 0,
    periods_substitute       INTEGER        NOT NULL DEFAULT 0,
    class_coeff              DECIMAL(3, 2)  NOT NULL DEFAULT 1.00,
    subject_coeff            DECIMAL(3, 2)  NOT NULL DEFAULT 1.00,
    converted_periods        DECIMAL(6, 2)  NOT NULL DEFAULT 0.00,
    price_per_period         DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    amount                   DECIMAL(15, 2) NOT NULL DEFAULT 0.00,
    note                     VARCHAR(255),
    created_at               TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_sd_sheet_class UNIQUE (salary_sheet_id, class_id),
    CONSTRAINT fk_sd_school      FOREIGN KEY (school_id)       REFERENCES schools(id)              ON DELETE CASCADE,
    CONSTRAINT fk_sd_sheet       FOREIGN KEY (salary_sheet_id) REFERENCES teacher_salary_sheet(id) ON DELETE CASCADE,
    CONSTRAINT fk_sd_class       FOREIGN KEY (class_id)        REFERENCES classes(id)              ON DELETE RESTRICT
);

-- ============================================================
-- INDEXES OPTIMIZING MULTI-TENANT QUERY PERFORMANCE
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_branches_school     ON school_branches(school_id);
CREATE INDEX IF NOT EXISTS idx_ay_school_current   ON academic_years(school_id, is_current);
CREATE INDEX IF NOT EXISTS idx_sem_school_ay       ON semesters(school_id, academic_year_id);
CREATE INDEX IF NOT EXISTS idx_dept_school         ON departments(school_id);
CREATE INDEX IF NOT EXISTS idx_users_school_active ON users(school_id, is_active);
CREATE INDEX IF NOT EXISTS idx_users_keycloak_id   ON users(keycloak_id);
CREATE INDEX IF NOT EXISTS idx_ur_user             ON user_roles(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_tc_school_dept      ON teachers(school_id, department_id);
CREATE INDEX IF NOT EXISTS idx_st_school_dept      ON students(school_id, department_id);
CREATE INDEX IF NOT EXISTS idx_crs_school_dept     ON courses(school_id, department_id);
CREATE INDEX IF NOT EXISTS idx_rm_school_type      ON rooms(school_id, room_type);
CREATE INDEX IF NOT EXISTS idx_cls_school_sem      ON classes(school_id, semester_id);
CREATE INDEX IF NOT EXISTS idx_cls_teacher         ON classes(teacher_id);
CREATE INDEX IF NOT EXISTS idx_schd_class          ON schedules(class_id);
CREATE INDEX IF NOT EXISTS idx_schd_room_dow       ON schedules(room_id, day_of_week, effective_from, effective_to);
CREATE INDEX IF NOT EXISTS idx_sexc_sched_date     ON schedule_exceptions(schedule_id, exception_date);
CREATE INDEX IF NOT EXISTS idx_enr_student         ON enrollments(student_id);
CREATE INDEX IF NOT EXISTS idx_att_sched_date      ON attendance_records(schedule_id, attendance_date);
CREATE INDEX IF NOT EXISTS idx_notif_user_unread   ON notifications(recipient_user_id, is_read);
CREATE INDEX IF NOT EXISTS idx_inv_student         ON tuition_invoices(student_id, semester_id);
CREATE INDEX IF NOT EXISTS idx_mat_class           ON class_materials(class_id);
CREATE INDEX IF NOT EXISTS idx_err_school_level    ON system_error_logs(school_id, error_level, created_at);
CREATE INDEX IF NOT EXISTS idx_aud_school_time     ON audit_logs(school_id, created_at);
CREATE INDEX IF NOT EXISTS idx_eval_class          ON teacher_evaluations(class_id);
-- Note: All 34 UUID columns (school_id, users_id, teachers_id, ...) have UNIQUE NOT NULL constraints,
-- so PostgreSQL automatically creates Unique B-Tree indexes for each column, optimizing UUID lookups to O(log N).

-- ============================================================
-- TRIGGER: AUTOMATICALLY UPDATE updated_at COLUMN
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
    tbl TEXT;
    tables_with_updated_at TEXT[] := ARRAY[
        'schools', 'school_branches', 'academic_years', 'semesters', 'departments',
        'role', 'users', 'user_roles', 'teachers', 'students', 'courses', 'rooms',
        'classes', 'schedules', 'schedule_exceptions', 'enrollments',
        'attendance_records', 'notifications', 'tuition_invoices',
        'student_semester_summaries', 'teacher_declarations', 'class_materials',
        'saas_plans', 'saas_subscriptions', 'saas_invoices',
        'class_teacher', 'salary_config', 'salary_grade', 'teacher_salary_sheet'
    ];
BEGIN
    FOREACH tbl IN ARRAY tables_with_updated_at
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I;', tbl, tbl);
        EXECUTE format(
            'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();',
            tbl, tbl
        );
    END LOOP;
END
$$;
