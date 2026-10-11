-- ============================================================
--  HỆ THỐNG QUẢN LÝ LỚP HỌC & LỊCH HỌC (Phiên bản có Audit Log)
-- ============================================================

-- SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE quan_ly_lop_hoc ENCODING 'UTF8';

-- \c quan_ly_lop_hoc;

-- ============================================================
-- 1. TRƯỜNG HỌC / TRUNG TÂM DẠY HỌC
-- ============================================================
CREATE TABLE schools (
  id               SERIAL NOT NULL,
  schools_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  code             VARCHAR(30)   NOT NULL ,
  name             VARCHAR(200)  NOT NULL,
  short_name       VARCHAR(50)   ,
  type VARCHAR(100) CHECK (type IN ('UNIVERSITY','COLLEGE','HIGH_SCHOOL', 'VOCATIONAL','LANGUAGE_CENTER','TUTORING_CENTER','OTHER'))
                   NOT NULL DEFAULT 'UNIVERSITY',
  accreditation    VARCHAR(100)  ,
  tax_code         VARCHAR(20)   ,
  email            VARCHAR(150),
  phone            VARCHAR(20),
  website          VARCHAR(255),
  logo_url         VARCHAR(500),
  established_date DATE,
  description      TEXT,
  is_active        BOOLEAN    NOT NULL DEFAULT 1,

  -- Audit Columns
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by       INTEGER  NULL,
  updated_by       INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_sch_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_sch_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_school_code ON schools (code);
CREATE INDEX idx_school_type ON schools (type);


-- ============================================================
-- 2. CƠ SỞ / CHI NHÁNH
-- ============================================================
CREATE TABLE school_branches (
  id         SERIAL NOT NULL,
  school_branches_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id  INTEGER  NOT NULL,
  code       VARCHAR(20)   NOT NULL ,
  name       VARCHAR(150)  NOT NULL,
  address    VARCHAR(300)  NOT NULL,
  city       VARCHAR(100),
  district   VARCHAR(100),
  phone      VARCHAR(20),
  email      VARCHAR(150),
  is_main    BOOLEAN    NOT NULL DEFAULT 0 ,
  is_active  BOOLEAN    NOT NULL DEFAULT 1,

  -- Audit Columns
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by INTEGER  NULL,
  updated_by INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_branch_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_sbr_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_sbr_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_branch ON school_branches (school_id, code);
CREATE INDEX idx_branch_school ON school_branches (school_id);


-- ============================================================
-- 3. NĂM HỌC  (thuộc trường)
-- ============================================================
CREATE TABLE academic_years (
  id         SERIAL NOT NULL,
  academic_years_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id  INTEGER  NOT NULL,
  name       VARCHAR(20)   NOT NULL ,
  start_date DATE          NOT NULL,
  end_date   DATE          NOT NULL,
  is_active  BOOLEAN    NOT NULL DEFAULT 1,

  -- Audit Columns
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by INTEGER  NULL,
  updated_by INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_year_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE RESTRICT,
  CONSTRAINT chk_year_dates CHECK (end_date > start_date),
  CONSTRAINT fk_ay_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_ay_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_year_name ON academic_years (school_id, name);
CREATE INDEX idx_year_school ON academic_years (school_id);


-- ============================================================
-- 4. HỌC KỲ
-- ============================================================
CREATE TABLE semesters (
  id               SERIAL NOT NULL,
  semesters_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id        INTEGER  NOT NULL,
  academic_year_id INTEGER  NOT NULL,
  name             VARCHAR(50)   NOT NULL ,
  start_date       DATE          NOT NULL,
  end_date         DATE          NOT NULL,
  is_active        BOOLEAN    NOT NULL DEFAULT 1,

  -- Audit Columns
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by       INTEGER  NULL,
  updated_by       INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_sem_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_sem_year   FOREIGN KEY (academic_year_id) REFERENCES academic_years(id) ON DELETE RESTRICT,
  CONSTRAINT chk_sem_dates CHECK (end_date > start_date),
  CONSTRAINT fk_sem_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_sem_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_semesters_school ON semesters (school_id);
CREATE INDEX idx_semesters_academic_year ON semesters (academic_year_id);
CREATE UNIQUE INDEX uq_semester ON semesters (academic_year_id, name);


-- ============================================================
-- 5. KHOA / BỘ MÔN  (thuộc trường)
-- ============================================================
CREATE TABLE departments (
  id          SERIAL NOT NULL,
  departments_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id   INTEGER  NOT NULL,
  code        VARCHAR(20)   NOT NULL ,
  name        VARCHAR(100)  NOT NULL,
  description TEXT,

  -- Audit Columns
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by  INTEGER  NULL,
  updated_by  INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_dept_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE RESTRICT,
  CONSTRAINT fk_dep_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_dep_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_dept_code ON departments (school_id, code);
CREATE INDEX idx_dept_school ON departments (school_id);


-- ============================================================
-- 6. VAI TRÒ (ROLE)
-- ============================================================
CREATE TABLE role (
  id          SERIAL NOT NULL,
  role_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  name        VARCHAR(30)   NOT NULL ,
  description TEXT,

  PRIMARY KEY (id)
);
CREATE UNIQUE INDEX uq_role_name ON role (name);

INSERT INTO role (name, description) VALUES
  ('SAAS_ADMIN',   'Quản trị viên hệ thống'),
  ('LECTURER', 'Giảng viên'),
  ('STUDENT', 'Sinh viên / Học sinh'),
  ('SCHOOL_ADMIN', 'Admin nha truong'),
  ('DEAN_OF_FACULTY', 'Trưởng khoa'),
  ('DEAN_OF_DEPARTMENT', 'Chủ nhiệm bộ môn');

-- ============================================================
-- 7. NGƯỜI DÙNG
-- ============================================================
CREATE TABLE users (
  id            SERIAL NOT NULL,
  users_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id     INTEGER  NOT NULL ,
  code          VARCHAR(20)   NOT NULL,
  full_name     VARCHAR(100)  NOT NULL,
  email         VARCHAR(150)  NOT NULL,
  password_hash VARCHAR(255)  NOT NULL,
  phone         VARCHAR(20),
  citizen_id_number VARCHAR(12) NOT NULL,
  address VARCHAR(500),

  date_of_birth DATE,
  gender VARCHAR(100) CHECK (gender IN ('MALE','FEMALE','OTHER')),
  avatar_url    VARCHAR(500),
  is_active     BOOLEAN    NOT NULL DEFAULT 1,
  last_login_at TIMESTAMP,

  -- Audit Columns
  created_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by    INTEGER  NULL,
  updated_by    INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_user_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE RESTRICT,
  CONSTRAINT fk_usr_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_usr_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_user_code ON users (school_id, code);
CREATE UNIQUE INDEX uq_user_email ON users (school_id, email);
CREATE INDEX idx_user_name ON users (full_name);
CREATE INDEX idx_user_school ON users (school_id);
CREATE INDEX idx_users_is_active ON users (school_id, is_active);


-- ============================================================
-- 8. NGƯỜI DÙNG ↔ VAI TRÒ
-- ============================================================
CREATE TABLE user_roles (
  user_roles_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id  INTEGER NOT NULL,
  user_id    INTEGER NOT NULL,
  role_id    INTEGER NOT NULL,
  granted_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  granted_by INTEGER NULL,

  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_ur_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES role(id) ON DELETE RESTRICT,
  CONSTRAINT fk_ur_gby  FOREIGN KEY (granted_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_user_roles_school ON user_roles (school_id);


-- ============================================================
-- 9. GIẢNG VIÊN
-- ============================================================
CREATE TABLE teachers (
  id             SERIAL NOT NULL,
  teachers_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id      INTEGER  NOT NULL,
  user_id        INTEGER  NOT NULL,
  department_id  INTEGER  NOT NULL,
  degree         VARCHAR(50)   ,
  specialization VARCHAR(150),
  join_date      DATE,
  bio            TEXT,

  -- Audit Columns
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by     INTEGER  NULL,
  updated_by     INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_teacher_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_teacher_user FOREIGN KEY (user_id)       REFERENCES users(id)       ON DELETE CASCADE,
  CONSTRAINT fk_teacher_dept FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
  CONSTRAINT fk_tch_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_tch_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_teachers_school ON teachers (school_id);
CREATE UNIQUE INDEX uq_teacher_user ON teachers (user_id);
CREATE INDEX idx_teacher_dept ON teachers (department_id);


-- ============================================================
-- 10. SINH VIÊN / HỌC SINH
-- ============================================================
CREATE TABLE students (
  id              SERIAL NOT NULL,
  students_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id       INTEGER  NOT NULL,
  user_id         INTEGER  NOT NULL,
  student_code    VARCHAR(20)   NOT NULL ,
  department_id   INTEGER  NOT NULL,
  enrollment_year SMALLINT          NOT NULL,
  major           VARCHAR(100),
  class_name      VARCHAR(50)   ,

  -- Audit Columns
  created_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by      INTEGER  NULL,
  updated_by      INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_student_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_student_user FOREIGN KEY (user_id)       REFERENCES users(id)       ON DELETE CASCADE,
  CONSTRAINT fk_student_dept FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
  CONSTRAINT fk_stu_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_stu_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_students_school ON students (school_id);
CREATE UNIQUE INDEX uq_student_user ON students (user_id);
CREATE UNIQUE INDEX uq_student_code ON students (student_code);
CREATE INDEX idx_student_dept ON students (department_id);


-- ============================================================
-- 11. MÔN HỌC
-- ============================================================
CREATE TABLE courses (
  id             SERIAL NOT NULL,
  courses_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id      INTEGER  NOT NULL,
  code           VARCHAR(20)   NOT NULL ,
  name           VARCHAR(150)  NOT NULL,
  credits        SMALLINT       NOT NULL DEFAULT 3,
  total_sessions SMALLINT       NOT NULL DEFAULT 30,
  description    TEXT,
  prerequisites  JSONB          ,
  department_id  INTEGER  NOT NULL,
  is_active      BOOLEAN    NOT NULL DEFAULT 1,

  -- Audit Columns
  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by     INTEGER  NULL,
  updated_by     INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_course_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_course_dept FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE RESTRICT,
  CONSTRAINT chk_credits    CHECK (credits BETWEEN 1 AND 10),
  CONSTRAINT chk_sessions   CHECK (total_sessions > 0),
  CONSTRAINT fk_crs_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_crs_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_course_code ON courses (school_id, code);
CREATE INDEX idx_courses_school ON courses (school_id);
CREATE INDEX idx_course_dept ON courses (department_id);
CREATE INDEX idx_courses_is_active ON courses (school_id, is_active);


-- ============================================================
-- 12. PHÒNG HỌC  (thuộc cơ sở)
-- ============================================================
CREATE TABLE rooms (
  id          SERIAL NOT NULL,
  rooms_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id   INTEGER  NOT NULL,
  branch_id   INTEGER  NOT NULL ,
  building    VARCHAR(50)   NOT NULL,
  room_number VARCHAR(20)   NOT NULL,
  capacity    SMALLINT      NOT NULL,
  room_type VARCHAR(100) CHECK (room_type IN ('CLASSROOM','LAB','SEMINAR','LECTURE_HALL','ONLINE'))
              NOT NULL DEFAULT 'CLASSROOM',
  equipment   JSONB,
  is_active   BOOLEAN    NOT NULL DEFAULT 1,

  -- Audit Columns
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by  INTEGER  NULL,
  updated_by  INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_room_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_room_branch FOREIGN KEY (branch_id) REFERENCES school_branches(id) ON DELETE RESTRICT,
  CONSTRAINT chk_capacity   CHECK (capacity > 0),
  CONSTRAINT fk_rm_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_rm_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_rooms_school ON rooms (school_id);
CREATE UNIQUE INDEX uq_room ON rooms (branch_id, building, room_number);
CREATE INDEX idx_room_branch ON rooms (branch_id);
CREATE INDEX idx_room_type ON rooms (room_type);
CREATE INDEX idx_rooms_is_active ON rooms (school_id, is_active);


-- ============================================================
-- 13. LỚP HỌC
-- ============================================================
CREATE TABLE classes (
  id           SERIAL NOT NULL,
  classes_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id    INTEGER  NOT NULL,
  code         VARCHAR(30)   NOT NULL,
  course_id    INTEGER  NOT NULL,
  semester_id  INTEGER  NOT NULL,
  teacher_id   INTEGER  NOT NULL,
  branch_id    INTEGER  NOT NULL ,
  max_students SMALLINT       NOT NULL DEFAULT 40,
  status VARCHAR(100) CHECK (status IN ('OPEN','CLOSED','IN_PROGRESS','COMPLETED','CANCELLED'))
               NOT NULL DEFAULT 'OPEN',
  notes        TEXT,

  -- Audit Columns
  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by   INTEGER  NULL,
  updated_by   INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_class_school   FOREIGN KEY (school_id)   REFERENCES schools(id)         ON DELETE CASCADE,
  CONSTRAINT fk_class_course   FOREIGN KEY (course_id)   REFERENCES courses(id)         ON DELETE RESTRICT,
  CONSTRAINT fk_class_semester FOREIGN KEY (semester_id) REFERENCES semesters(id)       ON DELETE RESTRICT,
  CONSTRAINT fk_class_teacher  FOREIGN KEY (teacher_id)  REFERENCES teachers(id)        ON DELETE RESTRICT,
  CONSTRAINT fk_class_branch   FOREIGN KEY (branch_id)   REFERENCES school_branches(id) ON DELETE RESTRICT,
  CONSTRAINT chk_max_students  CHECK (max_students > 0),
  CONSTRAINT fk_cls_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_cls_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE UNIQUE INDEX uq_class_code ON classes (school_id, code);
CREATE INDEX idx_classes_school ON classes (school_id);
CREATE INDEX idx_class_course ON classes (course_id);
CREATE INDEX idx_class_semester ON classes (semester_id);
CREATE INDEX idx_class_teacher ON classes (teacher_id);
CREATE INDEX idx_class_branch ON classes (branch_id);
CREATE INDEX idx_class_status ON classes (school_id, status);


-- ============================================================
-- 14. LỊCH HỌC
-- ============================================================
CREATE TABLE schedules (
  id          SERIAL NOT NULL,
  schedules_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id   INTEGER  NOT NULL,
  class_id    INTEGER  NOT NULL,
  room_id     INTEGER  NOT NULL,
  day_of_week SMALLINT       NOT NULL ,
  start_time  TIME          NOT NULL,
  end_time    TIME          NOT NULL,
  start_date  DATE          NOT NULL,
  end_date    DATE          NOT NULL,
  type VARCHAR(100) CHECK (type IN ('REGULAR','MAKEUP','EXAM','LAB','SEMINAR'))
              NOT NULL DEFAULT 'REGULAR',
  notes       TEXT,

  -- Audit Columns
  created_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at  TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by  INTEGER  NULL,
  updated_by  INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_sched_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_sched_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  CONSTRAINT fk_sched_room  FOREIGN KEY (room_id)  REFERENCES rooms(id)   ON DELETE RESTRICT,
  CONSTRAINT chk_sched_time CHECK (end_time > start_time),
  CONSTRAINT chk_sched_date CHECK (end_date >= start_date),
  CONSTRAINT chk_dow        CHECK (day_of_week BETWEEN 1 AND 7),
  CONSTRAINT fk_scd_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_scd_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_schedules_school ON schedules (school_id);
CREATE INDEX idx_sched_class ON schedules (class_id);
CREATE INDEX idx_sched_room ON schedules (room_id);
CREATE INDEX idx_sched_day ON schedules (day_of_week, start_time);


-- ============================================================
-- 15. NGOẠI LỆ LỊCH HỌC
-- ============================================================
CREATE TABLE schedule_exceptions (
  id                  SERIAL NOT NULL,
  schedule_exceptions_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id           INTEGER  NOT NULL,
  schedule_id         INTEGER  NOT NULL,
  exception_date      DATE          NOT NULL,
  reason              VARCHAR(255)  NOT NULL,
  exception_type VARCHAR(100) CHECK (exception_type IN ('CANCELLED','RESCHEDULED','ROOM_CHANGE', 'SUBSTITUTED'))
                      NOT NULL DEFAULT 'CANCELLED',
  replacement_date    DATE,
  replacement_room_id INTEGER,
  approval_status VARCHAR(100) CHECK (approval_status IN ('PENDING', 'APPROVED', 'REJECTED')) NOT NULL DEFAULT 'PENDING' ,
  proof_file_url VARCHAR(500) ,
   replacement_start_period INT ,
    replacement_end_period INT ,
    suggested_room VARCHAR(50) ,
    makeup_notes TEXT ,
    makeup_status VARCHAR(100) CHECK (makeup_status IN ('PENDING', 'APPROVED', 'REJECTED', 'COMPLETED')) DEFAULT NULL ,
    substitute_teacher_id INTEGER ,
    substitute_content TEXT ,
    substitute_status VARCHAR(100) CHECK (substitute_status IN ('PENDING', 'APPROVED', 'REJECTED')) ,


  -- Audit Columns
  created_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at          TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by          INTEGER  NULL,
  updated_by          INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_exc_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_exc_schedule FOREIGN KEY (schedule_id)         REFERENCES schedules(id) ON DELETE CASCADE,
  CONSTRAINT fk_exc_room     FOREIGN KEY (replacement_room_id) REFERENCES rooms(id)     ON DELETE SET NULL,
  CONSTRAINT fk_se_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_se_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_se_sub_teacher FOREIGN KEY (substitute_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL
);
CREATE INDEX idx_schedule_exceptions_school ON schedule_exceptions (school_id);
CREATE UNIQUE INDEX uq_exception ON schedule_exceptions (schedule_id, exception_date);
CREATE INDEX idx_exc_date ON schedule_exceptions (exception_date);
CREATE INDEX idx_exc_replacement_room ON schedule_exceptions (replacement_room_id);
CREATE INDEX idx_exc_substitute_teacher ON schedule_exceptions (substitute_teacher_id);


-- ============================================================
-- 16. ĐĂNG KÝ HỌC
-- ============================================================
CREATE TABLE enrollments (
  id              SERIAL NOT NULL,
  enrollments_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id       INTEGER    NOT NULL,
  student_id      INTEGER    NOT NULL,
  class_id        INTEGER    NOT NULL,
  enrollment_date TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP, -- Đóng vai trò created_at
  status VARCHAR(100) CHECK (status IN ('PENDING','ENROLLED','DROPPED','COMPLETED','FAILED'))
                  NOT NULL DEFAULT 'PENDING',
  grade_attendance FLOAT,
  grade_midterm   FLOAT    ,
  grade_final     FLOAT    ,
  grade_total     FLOAT    ,
  grade_letter    CHAR(2)         ,
  dropped_at      TIMESTAMP,
  drop_reason     VARCHAR(255),

  -- Audit Columns (Chỉ cần Update và CreatedBy nếu Admin đăng ký hộ)
  updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by      INTEGER  NULL,
  updated_by      INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_enroll_school  FOREIGN KEY (school_id)  REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_enroll_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_enroll_class   FOREIGN KEY (class_id)   REFERENCES classes(id)  ON DELETE RESTRICT,
  CONSTRAINT chk_grade_mid     CHECK (grade_midterm IS NULL OR grade_midterm BETWEEN 0 AND 10),
  CONSTRAINT chk_grade_fin     CHECK (grade_final   IS NULL OR grade_final   BETWEEN 0 AND 10),
  CONSTRAINT chk_grade_tot     CHECK (grade_total   IS NULL OR grade_total   BETWEEN 0 AND 10),
  CONSTRAINT fk_enr_cby FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_enr_uby FOREIGN KEY (updated_by) REFERENCES users(id) ON DELETE SET NULL
);
CREATE INDEX idx_enrollments_school ON enrollments (school_id);
CREATE UNIQUE INDEX uq_enrollment ON enrollments (student_id, class_id);
CREATE INDEX idx_enroll_student ON enrollments (student_id);
CREATE INDEX idx_enroll_class ON enrollments (class_id);
CREATE INDEX idx_enroll_status ON enrollments (school_id, status);


-- ============================================================
-- 17. ĐIỂM DANH
-- ============================================================
CREATE TABLE attendance_records (
  id              SERIAL NOT NULL,
  attendance_records_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id       INTEGER  NOT NULL,
  schedule_id     INTEGER  NOT NULL,
  student_id      INTEGER  NOT NULL,
  attendance_date DATE          NOT NULL,
  status VARCHAR(100) CHECK (status IN ('PRESENT','ABSENT','LATE','EXCUSED'))
                  NOT NULL DEFAULT 'ABSENT',
  note            TEXT,
  checked_by      INTEGER  ,
  checked_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP, -- (CreatedAt)

  -- Audit Columns
  updated_at      TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  updated_by      INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_att_school   FOREIGN KEY (school_id)   REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_att_schedule FOREIGN KEY (schedule_id) REFERENCES schedules(id) ON DELETE CASCADE,
  CONSTRAINT fk_att_student  FOREIGN KEY (student_id)  REFERENCES students(id)  ON DELETE CASCADE,
  CONSTRAINT fk_att_checker  FOREIGN KEY (checked_by)  REFERENCES users(id)     ON DELETE SET NULL,
  CONSTRAINT fk_att_uby      FOREIGN KEY (updated_by)  REFERENCES users(id)     ON DELETE SET NULL
);
CREATE INDEX idx_attendance_records_school ON attendance_records (school_id);
CREATE UNIQUE INDEX uq_attendance ON attendance_records (schedule_id, student_id, attendance_date);
CREATE INDEX idx_att_student ON attendance_records (student_id);
CREATE INDEX idx_att_date ON attendance_records (attendance_date);
CREATE INDEX idx_att_status ON attendance_records (school_id, status);


-- ============================================================
-- 18. THÔNG BÁO
-- ============================================================
CREATE TABLE notifications (
  id         SERIAL NOT NULL,
  notifications_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id  INTEGER  NOT NULL,
  user_id    INTEGER  NOT NULL,
  title      VARCHAR(200)  NOT NULL,
  body       TEXT          NOT NULL,
  type VARCHAR(100) CHECK (type IN ('SCHEDULE_CHANGE','GRADE','ENROLLMENT','SYSTEM','REMINDER'))
             NOT NULL DEFAULT 'SYSTEM',
  is_read    BOOLEAN    NOT NULL DEFAULT 0,
  ref_type   VARCHAR(50),
  ref_id     INTEGER,
  created_at TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  read_at    TIMESTAMP,

  PRIMARY KEY (id),
  CONSTRAINT fk_notif_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
CREATE INDEX idx_notifications_school ON notifications (school_id);
CREATE INDEX idx_notif_user ON notifications (user_id, is_read);

-- ============================================================
-- 19. HỌC PHI
-- ============================================================

CREATE TABLE tuition_invoices (
  id               SERIAL NOT NULL,
  tuition_invoices_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id        INTEGER  NOT NULL,
  student_id       INTEGER  NOT NULL,
  semester_id      INTEGER  NOT NULL,
  total_amount     DECIMAL(12,2) NOT NULL ,
  paid_amount      DECIMAL(12,2) NOT NULL DEFAULT 0 ,
  due_date         DATE          NOT NULL ,
  status VARCHAR(100) CHECK (status IN ('UNPAID','PARTIAL','PAID','OVERDUE','CANCELLED')) NOT NULL DEFAULT 'UNPAID',
  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  PRIMARY KEY (id),
  CONSTRAINT fk_inv_school   FOREIGN KEY (school_id)   REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_inv_student  FOREIGN KEY (student_id)  REFERENCES students(id),
  CONSTRAINT fk_inv_semester FOREIGN KEY (semester_id) REFERENCES semesters(id)
);
CREATE INDEX idx_tuition_invoices_school ON tuition_invoices (school_id);
CREATE UNIQUE INDEX uq_invoice ON tuition_invoices (student_id, semester_id);
CREATE INDEX idx_inv_semester ON tuition_invoices (semester_id);
CREATE INDEX idx_inv_status ON tuition_invoices (school_id, status);
CREATE INDEX idx_inv_due_date ON tuition_invoices (school_id, due_date);

-- ============================================================
-- 20. PHIEU THU
-- ============================================================
CREATE TABLE tuition_payments (
  id               SERIAL NOT NULL,
  tuition_payments_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id        INTEGER  NOT NULL,
  invoice_id       INTEGER  NOT NULL ,
  amount           DECIMAL(12,2) NOT NULL ,
  payment_method VARCHAR(100) CHECK (payment_method IN ('CASH','BANK_TRANSFER','MOMO','VNPAY','VISA')) NOT NULL,
  transaction_code VARCHAR(100)  ,
  payment_date     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(100) CHECK (status IN ('PENDING','SUCCESS','FAILED','REFUNDED')) NOT NULL DEFAULT 'PENDING',
  note             TEXT,

  PRIMARY KEY (id),
  CONSTRAINT fk_payment_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES tuition_invoices(id) ON DELETE RESTRICT
);
CREATE INDEX idx_tuition_payments_school ON tuition_payments (school_id);
CREATE INDEX idx_payment_invoice ON tuition_payments (invoice_id);
CREATE INDEX idx_payment_status ON tuition_payments (school_id, status);
CREATE INDEX idx_payment_date ON tuition_payments (school_id, payment_date);

-- ============================================================
-- 21. TỔNG KẾT HỌC KỲ (GPA, Điểm rèn luyện, Học bổng)
-- ============================================================
CREATE TABLE student_semester_summaries (
  id                 SERIAL NOT NULL,
  student_semester_summaries_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id          INTEGER  NOT NULL,
  student_id         INTEGER  NOT NULL,
  semester_id        INTEGER  NOT NULL,

  -- Thông tin tổng kết học thuật
  gpa                DECIMAL(4,2)  ,
  credits_earned     SMALLINT       ,

  -- Thông tin điểm rèn luyện
  conduct_score      SMALLINTEGER ,
  conduct_grade      VARCHAR(20)   ,

  -- Thông tin học bổng
  scholarship_name   VARCHAR(150)  ,
  scholarship_amount DECIMAL(12,2) ,

  notes              TEXT,

  -- Audit Columns
  created_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  created_by         INTEGER  NULL,
  updated_by         INTEGER  NULL,

  PRIMARY KEY (id),
  CONSTRAINT fk_sss_school   FOREIGN KEY (school_id)   REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_sss_student  FOREIGN KEY (student_id)  REFERENCES students(id) ON DELETE CASCADE,
  CONSTRAINT fk_sss_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE RESTRICT,
  CONSTRAINT fk_sss_cby      FOREIGN KEY (created_by)  REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_sss_uby      FOREIGN KEY (updated_by)  REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT chk_conduct     CHECK (conduct_score <= 100)
);
CREATE INDEX idx_student_semester_summaries_school ON student_semester_summaries (school_id);
CREATE UNIQUE INDEX uq_student_semester ON student_semester_summaries (student_id, semester_id);

CREATE TABLE teacher_declarations (
  id                SERIAL NOT NULL,
  teacher_declarations_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id         INTEGER  NOT NULL,
  teacher_id        INTEGER  NOT NULL,
  semester_id       INTEGER  NOT NULL,
  expected_sessions INT           NOT NULL DEFAULT 0 ,
  expected_classes  INT           NOT NULL DEFAULT 0 ,
  notes             TEXT,

  created_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  PRIMARY KEY (id),
  CONSTRAINT fk_td_school   FOREIGN KEY (school_id)   REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_td_teacher  FOREIGN KEY (teacher_id)  REFERENCES teachers(id)  ON DELETE CASCADE,
  CONSTRAINT fk_td_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE RESTRICT
);
CREATE INDEX idx_teacher_declarations_school ON teacher_declarations (school_id);
CREATE UNIQUE INDEX uq_declaration ON teacher_declarations (teacher_id, semester_id);

CREATE TABLE class_materials (
  id           SERIAL NOT NULL,
  class_materials_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id    INTEGER  NOT NULL,
  class_id     INTEGER  NOT NULL ,
  title        VARCHAR(200)  NOT NULL ,
  file_name    VARCHAR(255)  NOT NULL ,
  file_url     VARCHAR(500)  NOT NULL ,
  file_size    BIGINT        NOT NULL ,
  content_type VARCHAR(100)  ,
  doc_type VARCHAR(100) CHECK (doc_type IN ('SLIDE', 'EXERCISE', 'SYLLABUS', 'REFERENCE', 'OTHER')) NOT NULL DEFAULT 'OTHER',
  uploaded_by  INTEGER  NOT NULL ,

  created_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at   TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  PRIMARY KEY (id),
  CONSTRAINT fk_mat_school  FOREIGN KEY (school_id)   REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_mat_class   FOREIGN KEY (class_id)    REFERENCES classes(id)  ON DELETE CASCADE,
  CONSTRAINT fk_mat_teacher FOREIGN KEY (uploaded_by) REFERENCES teachers(id) ON DELETE CASCADE
);
CREATE INDEX idx_class_materials_school ON class_materials (school_id);
CREATE INDEX idx_mat_class ON class_materials (class_id);
CREATE INDEX idx_mat_type ON class_materials (doc_type);

SELECT * FROM class_materials;

-- Bật lại kiểm tra khóa ngoại sau khi đã tạo xong các bảng
-- SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- SAAS
-- ============================================================
-- BẢNG 1: GÓI CƯỚC SAAS (Saas Plans)
CREATE TABLE saas_plans (
  id             SERIAL NOT NULL,
  saas_plans_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  code           VARCHAR(50)   NOT NULL UNIQUE ,
  name           VARCHAR(100)  NOT NULL,
  monthly_price  DECIMAL(12,2) NOT NULL DEFAULT 0,
  yearly_price   DECIMAL(12,2) NOT NULL DEFAULT 0,
  max_students   INT           NOT NULL ,
  max_storage_gb INT           NOT NULL ,
  features       JSONB          ,
  is_active      BOOLEAN    NOT NULL DEFAULT 1,

  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

-- BẢNG 2: LỊCH SỬ THUÊ BAO CỦA TRƯỜNG (Saas Subscriptions)
CREATE TABLE saas_subscriptions (
  id             SERIAL NOT NULL,
  saas_subscriptions_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id      INTEGER  NOT NULL,
  plan_id        INTEGER  NOT NULL,
  start_date     DATE          NOT NULL,
  end_date       DATE          NOT NULL ,
  billing_cycle VARCHAR(100) CHECK (billing_cycle IN ('MONTHLY', 'YEARLY', 'LIFETIME')) NOT NULL,
  status VARCHAR(100) CHECK (status IN ('ACTIVE', 'EXPIRED', 'SUSPENDED', 'CANCELLED')) NOT NULL DEFAULT 'ACTIVE',

  created_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at     TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP ,

  PRIMARY KEY (id),
  CONSTRAINT fk_sub_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_sub_plan   FOREIGN KEY (plan_id)   REFERENCES saas_plans(id)
);
CREATE INDEX idx_saas_subscriptions_school ON saas_subscriptions (school_id);
CREATE INDEX idx_sub_plan ON saas_subscriptions (plan_id);
CREATE INDEX idx_sub_status ON saas_subscriptions (school_id, status);

-- BẢNG 3: HÓA ĐƠN THU TIỀN PHẦN MỀM (Saas Invoices)
-- Bảng này độc lập với tuition_invoices (thu học phí của sinh viên)
CREATE TABLE saas_invoices (
  id               SERIAL NOT NULL,
  saas_invoices_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id        INTEGER  NOT NULL,
  subscription_id  INTEGER  NOT NULL,
  amount           DECIMAL(12,2) NOT NULL,
  payment_status VARCHAR(100) CHECK (payment_status IN ('PENDING', 'PAID', 'FAILED')) NOT NULL DEFAULT 'PENDING',
  payment_method   VARCHAR(50)   ,
  paid_at          TIMESTAMP     NULL,

  created_at       TIMESTAMP     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_sinv_school FOREIGN KEY (school_id)       REFERENCES schools(id),
  CONSTRAINT fk_sinv_sub    FOREIGN KEY (subscription_id) REFERENCES saas_subscriptions(id)
);
CREATE INDEX idx_saas_invoices_school ON saas_invoices (school_id);
CREATE INDEX idx_sinv_subscription ON saas_invoices (subscription_id);
CREATE INDEX idx_sinv_payment_status ON saas_invoices (school_id, payment_status);

-- BẢNG 4: NHẬT KÝ LỖI HỆ THỐNG (System Error Logs)
CREATE TABLE system_error_logs (
  id            BIGSERIAL NOT NULL,
  system_error_logs_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id     INTEGER    NULL ,
  endpoint      VARCHAR(255)    NOT NULL ,
  error_message TEXT            NOT NULL ,
  stack_trace   TEXT        ,
  user_agent    VARCHAR(255)    ,
  is_resolved   BOOLEAN      NOT NULL DEFAULT 0 ,

  created_at    TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_err_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE SET NULL
);
CREATE INDEX idx_system_error_logs_school ON system_error_logs (school_id);
CREATE INDEX idx_err_resolved ON system_error_logs (school_id, is_resolved);
CREATE INDEX idx_err_created_at ON system_error_logs (school_id, created_at);

-- ============================================================
-- 6. BẢNG AUDIT_LOGS (6 entries)
-- ============================================================

CREATE TABLE audit_logs (
    id BIGSERIAL PRIMARY KEY,
  audit_logs_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
    school_id INT,
    user_email VARCHAR(255) NOT NULL,
    action VARCHAR(20) NOT NULL,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT,
    ip_address VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (school_id) REFERENCES schools(id)
);
CREATE INDEX idx_audit_logs_school ON audit_logs (school_id);
CREATE INDEX idx_audit_table ON audit_logs (school_id, table_name);
CREATE INDEX idx_audit_action ON audit_logs (school_id, action);
CREATE INDEX idx_audit_created_at ON audit_logs (school_id, created_at);

-- Tạo bảng lưu trữ đánh giá của sinh viên
CREATE TABLE teacher_evaluations (
  id SERIAL NOT NULL,
  teacher_evaluations_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id INTEGER NOT NULL,
  teacher_id INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  class_id INTEGER NOT NULL,

  -- 5 Tiêu chí đánh giá (Thang điểm 5)
  score_knowledge DECIMAL(2,1) NOT NULL ,
  score_method DECIMAL(2,1) NOT NULL ,
  score_interaction DECIMAL(2,1) NOT NULL ,
  score_materials DECIMAL(2,1) NOT NULL ,
  score_punctuality DECIMAL(2,1) NOT NULL ,

  comment TEXT ,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  -- Lưu ý: Có thể có cột student_id để hệ thống check trùng, nhưng TUYỆT ĐỐI KHÔNG JOIN để lấy tên.
  student_id INTEGER NULL,
  
  
  

  PRIMARY KEY (id),
  CONSTRAINT fk_eval_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_eval_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
  CONSTRAINT fk_eval_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE,
  CONSTRAINT fk_eval_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
);
CREATE INDEX idx_teacher_evaluations_school ON teacher_evaluations (school_id);
CREATE INDEX idx_eval_teacher ON teacher_evaluations (teacher_id);
CREATE INDEX idx_eval_semester ON teacher_evaluations (semester_id);
CREATE INDEX idx_eval_class ON teacher_evaluations (class_id);


-- ============================================================
-- BẢNG MỞ RỘNG (Giáo viên, Lương, Phân công)
-- ============================================================

CREATE TABLE class_teacher (
  id SERIAL NOT NULL,
  class_teacher_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id INTEGER NOT NULL,
  class_id INTEGER NOT NULL,
  teacher_id INTEGER NOT NULL,
  role VARCHAR(100) CHECK (role IN ('MAIN', 'ASSISTANT', 'SUBSTITUTE')) NOT NULL DEFAULT 'MAIN',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (id),
  CONSTRAINT fk_ct_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_ct_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
  CONSTRAINT fk_ct_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE
);
CREATE INDEX idx_class_teacher_school ON class_teacher (school_id);
CREATE UNIQUE INDEX uq_class_teacher ON class_teacher (class_id, teacher_id);
CREATE INDEX idx_ct_teacher ON class_teacher (teacher_id);

CREATE TABLE salary_config (
  id SERIAL NOT NULL,
  salary_config_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  role_name VARCHAR(50) NOT NULL,
  base_salary DECIMAL(12,2) NOT NULL,
  allowance DECIMAL(12,2) DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE salary_grade (
  id SERIAL NOT NULL,
  salary_grade_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  grade_name VARCHAR(50) NOT NULL,
  multiplier DECIMAL(4,2) NOT NULL DEFAULT 1.0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE teacher_salary_sheet (
  id SERIAL NOT NULL,
  teacher_salary_sheet_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id INTEGER NOT NULL,
  teacher_id INTEGER NOT NULL,
  semester_id INTEGER NOT NULL,
  total_hours INT NOT NULL DEFAULT 0,
  total_salary DECIMAL(12,2) NOT NULL DEFAULT 0,
  status VARCHAR(100) CHECK (status IN ('PENDING', 'PAID', 'CANCELLED')) NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ,
  PRIMARY KEY (id),
  CONSTRAINT fk_tss_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_tss_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
  CONSTRAINT fk_tss_semester FOREIGN KEY (semester_id) REFERENCES semesters(id) ON DELETE CASCADE
);
CREATE INDEX idx_teacher_salary_sheet_school ON teacher_salary_sheet (school_id);
CREATE INDEX idx_tss_teacher ON teacher_salary_sheet (teacher_id);
CREATE INDEX idx_tss_semester ON teacher_salary_sheet (semester_id);
CREATE INDEX idx_tss_status ON teacher_salary_sheet (school_id, status);

CREATE TABLE teacher_salary_detail (
  id SERIAL NOT NULL,
  teacher_salary_detail_id UUID DEFAULT gen_random_uuid() UNIQUE NOT NULL,
  school_id INTEGER NOT NULL,
  sheet_id INTEGER NOT NULL,
  class_id INTEGER NOT NULL,
  hours INT NOT NULL DEFAULT 0,
  amount DECIMAL(12,2) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  CONSTRAINT fk_tsd_school FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
  CONSTRAINT fk_tsd_sheet FOREIGN KEY (sheet_id) REFERENCES teacher_salary_sheet(id) ON DELETE CASCADE,
  CONSTRAINT fk_tsd_class FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE RESTRICT
);
CREATE INDEX idx_teacher_salary_detail_school ON teacher_salary_detail (school_id);
CREATE INDEX idx_tsd_sheet ON teacher_salary_detail (sheet_id);
CREATE INDEX idx_tsd_class ON teacher_salary_detail (class_id);


-- ============================================================
-- TRIGGER: Tu dong cap nhat updated_at
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP;
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_schools_modtime
BEFORE UPDATE ON schools
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_school_branches_modtime
BEFORE UPDATE ON school_branches
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_academic_years_modtime
BEFORE UPDATE ON academic_years
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_semesters_modtime
BEFORE UPDATE ON semesters
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_departments_modtime
BEFORE UPDATE ON departments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_modtime
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teachers_modtime
BEFORE UPDATE ON teachers
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_students_modtime
BEFORE UPDATE ON students
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_courses_modtime
BEFORE UPDATE ON courses
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rooms_modtime
BEFORE UPDATE ON rooms
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_classes_modtime
BEFORE UPDATE ON classes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedules_modtime
BEFORE UPDATE ON schedules
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_schedule_exceptions_modtime
BEFORE UPDATE ON schedule_exceptions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_enrollments_modtime
BEFORE UPDATE ON enrollments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_attendance_records_modtime
BEFORE UPDATE ON attendance_records
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tuition_invoices_modtime
BEFORE UPDATE ON tuition_invoices
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_student_semester_summaries_modtime
BEFORE UPDATE ON student_semester_summaries
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teacher_declarations_modtime
BEFORE UPDATE ON teacher_declarations
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_class_materials_modtime
BEFORE UPDATE ON class_materials
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saas_subscriptions_modtime
BEFORE UPDATE ON saas_subscriptions
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_class_teacher_modtime
BEFORE UPDATE ON class_teacher
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_teacher_salary_sheet_modtime
BEFORE UPDATE ON teacher_salary_sheet
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- Table Comments
COMMENT ON TABLE schools IS 'Trường học / Trung tâm dạy học';
COMMENT ON TABLE school_branches IS 'Cơ sở / Chi nhánh của trường';
COMMENT ON TABLE academic_years IS 'Năm học';
COMMENT ON TABLE semesters IS 'Học kỳ';
COMMENT ON TABLE departments IS 'Khoa / Bộ môn';
COMMENT ON TABLE role IS 'Vai trò hệ thống';
COMMENT ON TABLE users IS 'Tài khoản người dùng';
COMMENT ON TABLE user_roles IS 'Phân quyền người dùng';
COMMENT ON TABLE teachers IS 'Hồ sơ giảng viên';
COMMENT ON TABLE students IS 'Hồ sơ sinh viên';
COMMENT ON TABLE courses IS 'Môn học / Học phần';
COMMENT ON TABLE rooms IS 'Phòng học';
COMMENT ON TABLE classes IS 'Lớp học (instance của môn học)';
COMMENT ON TABLE schedules IS 'Lịch học (ca học lặp theo tuần)';
COMMENT ON TABLE schedule_exceptions IS 'Ngoại lệ lịch học';
COMMENT ON TABLE enrollments IS 'Đăng ký học phần';
COMMENT ON TABLE attendance_records IS 'Bảng điểm danh theo buổi học';
COMMENT ON TABLE notifications IS 'Thông báo người dùng';
COMMENT ON TABLE tuition_invoices IS 'Hóa đơn công nợ học phí theo học kỳ';
COMMENT ON TABLE tuition_payments IS 'Lịch sử giao dịch thanh toán học phí';
COMMENT ON TABLE student_semester_summaries IS 'Tổng kết học kỳ của sinh viên (GPA, Rèn luyện, Học bổng)';
COMMENT ON TABLE teacher_declarations IS 'Khai báo thông tin giảng dạy dự kiến của Giảng viên';
COMMENT ON TABLE class_materials IS 'Tài liệu giảng dạy của lớp học phần';
COMMENT ON TABLE saas_plans IS 'Danh mục gói cước phần mềm EduSpace';
COMMENT ON TABLE saas_subscriptions IS 'Hợp đồng thuê bao của các trường';
COMMENT ON TABLE saas_invoices IS 'Hóa đơn thu tiền thuê phần mềm từ các trường';
COMMENT ON TABLE system_error_logs IS 'Nhật ký bắt lỗi toàn hệ thống';
COMMENT ON TABLE teacher_evaluations IS 'Bảng lưu kết quả khảo sát giảng viên';
COMMENT ON TABLE class_teacher IS 'Phân công giảng viên vào lớp';
COMMENT ON TABLE salary_config IS 'Cấu hình lương cơ bản';
COMMENT ON TABLE salary_grade IS 'Bậc lương';
COMMENT ON TABLE teacher_salary_sheet IS 'Bảng lương tổng của giảng viên theo kỳ';
COMMENT ON TABLE teacher_salary_detail IS 'Chi tiết lương theo từng lớp';

-- Column Comments
COMMENT ON COLUMN schools.code IS 'Mã trường: HCMUT, IELTS_CENTER…';
COMMENT ON COLUMN schools.short_name IS 'Tên viết tắt';
COMMENT ON COLUMN schools.accreditation IS 'Cơ quan kiểm định / cấp phép';
COMMENT ON COLUMN schools.tax_code IS 'Mã số thuế';
COMMENT ON COLUMN school_branches.code IS 'Mã cơ sở: CS1, CS2…';
COMMENT ON COLUMN school_branches.is_main IS '1 = Cơ sở chính';
COMMENT ON COLUMN academic_years.name IS 'VD: 2024-2025';
COMMENT ON COLUMN semesters.name IS 'VD: Học kỳ 1, Học kỳ hè';
COMMENT ON COLUMN departments.code IS 'Mã khoa: CNTT, KTKT…';
COMMENT ON COLUMN role.name IS 'admin | teacher | student';
COMMENT ON COLUMN users.school_id IS 'Người dùng thuộc trường nào';
COMMENT ON COLUMN teachers.degree IS 'Cử nhân, Thạc sĩ, Tiến sĩ…';
COMMENT ON COLUMN students.student_code IS 'Mã sinh viên';
COMMENT ON COLUMN students.class_name IS 'Lớp hành chính, VD: CNTT21A';
COMMENT ON COLUMN courses.code IS 'Mã môn: INT101';
COMMENT ON COLUMN courses.prerequisites IS 'Mảng course_id điều kiện tiên quyết';
COMMENT ON COLUMN rooms.branch_id IS 'Cơ sở chứa phòng học này';
COMMENT ON COLUMN classes.branch_id IS 'Lớp học tại cơ sở nào';
COMMENT ON COLUMN schedules.day_of_week IS '1=Thứ 2 … 7=Chủ nhật';
COMMENT ON COLUMN schedule_exceptions.approval_status IS 'Trạng thái duyệt đơn';
COMMENT ON COLUMN schedule_exceptions.proof_file_url IS 'Đường dẫn file minh chứng (Cloudinary/S3...)';
COMMENT ON COLUMN schedule_exceptions.replacement_start_period IS 'Tiết bắt đầu ca dạy bù (VD: 1)';
COMMENT ON COLUMN schedule_exceptions.replacement_end_period IS 'Tiết kết thúc ca dạy bù (VD: 3)';
COMMENT ON COLUMN schedule_exceptions.suggested_room IS 'Phòng học đề xuất (VD: A401)';
COMMENT ON COLUMN schedule_exceptions.makeup_notes IS 'Ghi chú cho đơn dạy bù';
COMMENT ON COLUMN schedule_exceptions.makeup_status IS 'Trạng thái duyệt đơn dạy bù';
COMMENT ON COLUMN schedule_exceptions.substitute_teacher_id IS 'GV được nhờ dạy thay';
COMMENT ON COLUMN schedule_exceptions.substitute_content IS 'Nội dung bài dạy thay';
COMMENT ON COLUMN schedule_exceptions.substitute_status IS 'Trạng thái duyệt dạy thay';
COMMENT ON COLUMN enrollments.grade_midterm IS 'Điểm giữa kỳ (0-10)';
COMMENT ON COLUMN enrollments.grade_final IS 'Điểm cuối kỳ (0-10)';
COMMENT ON COLUMN enrollments.grade_total IS 'Điểm tổng kết (0-10)';
COMMENT ON COLUMN enrollments.grade_letter IS 'A+, A, B+, B, C+, C, D+, D, F';
COMMENT ON COLUMN attendance_records.checked_by IS 'user_id người điểm danh (CreatedBy)';
COMMENT ON COLUMN tuition_invoices.total_amount IS 'Tổng tiền học phí học kỳ';
COMMENT ON COLUMN tuition_invoices.paid_amount IS 'Số tiền đã đóng';
COMMENT ON COLUMN tuition_invoices.due_date IS 'Hạn chót nộp học phí';
COMMENT ON COLUMN tuition_payments.invoice_id IS 'Thanh toán cho hóa đơn nào';
COMMENT ON COLUMN tuition_payments.amount IS 'Số tiền giao dịch';
COMMENT ON COLUMN tuition_payments.transaction_code IS 'Mã giao dịch từ ngân hàng/ví điện tử';
COMMENT ON COLUMN student_semester_summaries.gpa IS 'Điểm trung bình học kỳ (hệ 4 hoặc 10)';
COMMENT ON COLUMN student_semester_summaries.credits_earned IS 'Số tín chỉ tích lũy được trong kỳ';
COMMENT ON COLUMN student_semester_summaries.conduct_score IS 'Điểm rèn luyện (0-100)';
COMMENT ON COLUMN student_semester_summaries.conduct_grade IS 'Xếp loại rèn luyện (VD: Xuất sắc, Tốt, Khá)';
COMMENT ON COLUMN student_semester_summaries.scholarship_name IS 'Tên học bổng đạt được (nếu có)';
COMMENT ON COLUMN student_semester_summaries.scholarship_amount IS 'Số tiền học bổng';
COMMENT ON COLUMN teacher_declarations.expected_sessions IS 'Số tiết dạy dự kiến';
COMMENT ON COLUMN teacher_declarations.expected_classes IS 'Số lớp phụ trách';
COMMENT ON COLUMN class_materials.class_id IS 'Tài liệu thuộc lớp học phần nào';
COMMENT ON COLUMN class_materials.title IS 'Tên hiển thị: Slide Chương 1...';
COMMENT ON COLUMN class_materials.file_name IS 'Tên file gốc giảng viên tải lên';
COMMENT ON COLUMN class_materials.file_url IS 'Đường dẫn HTTPS công khai từ Cloudinary';
COMMENT ON COLUMN class_materials.file_size IS 'Dung lượng file (tính bằng Byte)';
COMMENT ON COLUMN class_materials.content_type IS 'Định dạng file (MIME type)';
COMMENT ON COLUMN class_materials.uploaded_by IS 'ID của giảng viên tải lên';
COMMENT ON COLUMN saas_plans.code IS 'VD: BASIC, PRO, ENTERPRISE';
COMMENT ON COLUMN saas_plans.max_students IS '-1 là không giới hạn (Unlimited)';
COMMENT ON COLUMN saas_plans.max_storage_gb IS '-1 là không giới hạn (Unlimited)';
COMMENT ON COLUMN saas_plans.features IS '["attendance", "materials", "salary"]';
COMMENT ON COLUMN saas_subscriptions.end_date IS 'Ngày hết hạn phần mềm';
COMMENT ON COLUMN saas_invoices.payment_method IS 'Momo, VNPay, Bank Transfer';
COMMENT ON COLUMN system_error_logs.school_id IS 'Lỗi xảy ra ở trường nào (nếu có)';
COMMENT ON COLUMN system_error_logs.endpoint IS 'API URL bị lỗi';
COMMENT ON COLUMN system_error_logs.error_message IS 'Nội dung lỗi ngắn';
COMMENT ON COLUMN system_error_logs.stack_trace IS 'Toàn bộ Stack Trace của Java';
COMMENT ON COLUMN system_error_logs.user_agent IS 'Thiết bị/Trình duyệt của khách hàng';
COMMENT ON COLUMN system_error_logs.is_resolved IS '0: Chưa fix, 1: Đã fix';
COMMENT ON COLUMN teacher_evaluations.score_knowledge IS 'Kiến thức chuyên môn';
COMMENT ON COLUMN teacher_evaluations.score_method IS 'Phương pháp giảng dạy';
COMMENT ON COLUMN teacher_evaluations.score_interaction IS 'Tương tác với sinh viên';
COMMENT ON COLUMN teacher_evaluations.score_materials IS 'Tài liệu giảng dạy';
COMMENT ON COLUMN teacher_evaluations.score_punctuality IS 'Đúng giờ, kỷ luật';
COMMENT ON COLUMN teacher_evaluations.comment IS 'Nhận xét từ sinh viên';
