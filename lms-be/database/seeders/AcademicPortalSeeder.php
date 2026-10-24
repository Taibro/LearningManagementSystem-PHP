<?php

namespace Database\Seeders;

use App\Models\Classroom;
use App\Models\CourseClass;
use App\Models\CourseRegistration;
use App\Models\Faculty;
use App\Models\Schedule;
use App\Models\Semester;
use App\Models\Subject;
use App\Models\Tuition;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AcademicPortalSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Khoa
        $faculty = Faculty::firstOrCreate(
            ['faculty_code' => 'CNTT'],
            ['name' => 'Khoa Công Nghệ Thông Tin']
        );

        // 2. Hoc ky
        $semester = Semester::firstOrCreate(
            ['semester_code' => 'HK1_2026_2027'],
            [
                'name' => 'Học kỳ 1 năm học 2026 - 2027',
                'academic_year_start' => 2026,
                'academic_year_end' => 2027,
                'tuition_fee_per_credit' => 450000.00,
                'start_date' => '2026-09-01',
                'end_date' => '2027-01-15',
                'tuition_deadline' => '2026-11-30',
                'is_active' => true,
            ]
        );

        // 3. Giang vien
        $gvHung = User::firstOrCreate(
            ['email' => 'hungtv@huit.edu.vn'],
            [
                'name' => 'Trần Văn Hùng',
                'user_code' => 'GV0101',
                'role' => 'lecturer',
                'password' => Hash::make('password'),
            ]
        );

        $gvNghia = User::firstOrCreate(
            ['email' => 'nghiadnt@huit.edu.vn'],
            [
                'name' => 'Đinh Nguyễn Trọng Nghĩa',
                'user_code' => 'GV0102',
                'role' => 'lecturer',
                'password' => Hash::make('password'),
            ]
        );

        $gvHoang = User::firstOrCreate(
            ['email' => 'hoangdh@huit.edu.vn'],
            [
                'name' => 'Đinh Huy Hoàng',
                'user_code' => 'GV0103',
                'role' => 'lecturer',
                'password' => Hash::make('password'),
            ]
        );

        $gvThu = User::firstOrCreate(
            ['email' => 'thunma@huit.edu.vn'],
            [
                'name' => 'Ngô Minh Anh Thư',
                'user_code' => 'GV0104',
                'role' => 'lecturer',
                'password' => Hash::make('password'),
            ]
        );

        // 4. Sinh vien
        $student = User::firstOrCreate(
            ['email' => 'thinhphan@student.huit.edu.vn'],
            [
                'name' => 'Phan Sĩ Thịnh',
                'user_code' => '2001210001',
                'role' => 'student',
                'class_name' => '14DHTH07',
                'password' => Hash::make('password'),
            ]
        );

        // 5. Mon hoc
        $subOpenSource = Subject::firstOrCreate(
            ['subject_code' => '0101101978'],
            [
                'name' => 'Lập trình mã nguồn mở',
                'credits' => 2,
                'theory_periods' => 0,
                'practice_periods' => 60,
                'is_elective' => true,
                'faculty_id' => $faculty->id,
            ]
        );

        $subNoSQL = Subject::firstOrCreate(
            ['subject_code' => '0101101981'],
            [
                'name' => 'Dữ liệu NoSQL',
                'credits' => 2,
                'theory_periods' => 0,
                'practice_periods' => 60,
                'is_elective' => true,
                'faculty_id' => $faculty->id,
            ]
        );

        $subBigData = Subject::firstOrCreate(
            ['subject_code' => '0101101971'],
            [
                'name' => 'Nhập môn Big Data',
                'credits' => 2,
                'theory_periods' => 30,
                'practice_periods' => 0,
                'is_elective' => false,
                'faculty_id' => $faculty->id,
            ]
        );

        $subIoT = Subject::firstOrCreate(
            ['subject_code' => '0101101975'],
            [
                'name' => 'Internet of Things',
                'credits' => 3,
                'theory_periods' => 45,
                'practice_periods' => 0,
                'is_elective' => false,
                'faculty_id' => $faculty->id,
            ]
        );

        // 6. Phong hoc
        $roomA105 = Classroom::firstOrCreate(
            ['room_code' => 'A105'],
            ['building' => '140 Lê Trọng Tấn', 'room_type' => 'computer_lab', 'capacity' => 60]
        );

        $roomA206 = Classroom::firstOrCreate(
            ['room_code' => 'A206'],
            ['building' => '140 Lê Trọng Tấn', 'room_type' => 'computer_lab', 'capacity' => 60]
        );

        $roomB202 = Classroom::firstOrCreate(
            ['room_code' => 'B202'],
            ['building' => '140 Lê Trọng Tấn', 'room_type' => 'theory', 'capacity' => 80]
        );

        $roomA301 = Classroom::firstOrCreate(
            ['room_code' => 'A301'],
            ['building' => '140 Lê Trọng Tấn', 'room_type' => 'theory', 'capacity' => 80]
        );

        // 7. Lop hoc phan
        $classOpenSource = CourseClass::firstOrCreate(
            ['class_code' => '14DHTH07 - 010110197807'],
            [
                'subject_id' => $subOpenSource->id,
                'semester_id' => $semester->id,
                'lecturer_id' => $gvHung->id,
                'max_students' => 60,
                'current_students' => 1,
                'status' => 'open',
            ]
        );

        $classNoSQL = CourseClass::firstOrCreate(
            ['class_code' => '14DHTH07 - 010110198107'],
            [
                'subject_id' => $subNoSQL->id,
                'semester_id' => $semester->id,
                'lecturer_id' => $gvThu->id,
                'max_students' => 60,
                'current_students' => 1,
                'status' => 'open',
            ]
        );

        $classBigData = CourseClass::firstOrCreate(
            ['class_code' => '14DHTH01 - 010110197101'],
            [
                'subject_id' => $subBigData->id,
                'semester_id' => $semester->id,
                'lecturer_id' => $gvNghia->id,
                'max_students' => 80,
                'current_students' => 1,
                'status' => 'open',
            ]
        );

        $classIoT = CourseClass::firstOrCreate(
            ['class_code' => '14DHTH01 - 010110197505'],
            [
                'subject_id' => $subIoT->id,
                'semester_id' => $semester->id,
                'lecturer_id' => $gvHoang->id,
                'max_students' => 80,
                'current_students' => 1,
                'status' => 'open',
            ]
        );

        // 8. Lich hoc (TKB)
        Schedule::firstOrCreate(
            ['course_class_id' => $classOpenSource->id, 'day_of_week' => 8, 'start_period' => 1],
            [
                'classroom_id' => $roomA105->id,
                'shift' => 1,
                'end_period' => 5,
                'lesson_type' => 'practice',
            ]
        );

        Schedule::firstOrCreate(
            ['course_class_id' => $classNoSQL->id, 'day_of_week' => 8, 'start_period' => 7],
            [
                'classroom_id' => $roomA206->id,
                'shift' => 3,
                'end_period' => 11,
                'lesson_type' => 'practice',
            ]
        );

        Schedule::firstOrCreate(
            ['course_class_id' => $classBigData->id, 'day_of_week' => 2, 'start_period' => 7],
            [
                'classroom_id' => $roomB202->id,
                'shift' => 3,
                'end_period' => 9,
                'lesson_type' => 'theory',
            ]
        );

        Schedule::firstOrCreate(
            ['course_class_id' => $classIoT->id, 'day_of_week' => 2, 'start_period' => 10],
            [
                'classroom_id' => $roomA301->id,
                'shift' => 4,
                'end_period' => 12,
                'lesson_type' => 'theory',
            ]
        );

        // 9. Dang ky hoc phan cua sinh vien
        CourseRegistration::firstOrCreate([
            'student_id' => $student->id,
            'course_class_id' => $classOpenSource->id,
        ], [
            'semester_id' => $semester->id,
            'status' => 'registered',
        ]);

        CourseRegistration::firstOrCreate([
            'student_id' => $student->id,
            'course_class_id' => $classNoSQL->id,
        ], [
            'semester_id' => $semester->id,
            'status' => 'registered',
        ]);

        CourseRegistration::firstOrCreate([
            'student_id' => $student->id,
            'course_class_id' => $classBigData->id,
        ], [
            'semester_id' => $semester->id,
            'status' => 'registered',
        ]);

        CourseRegistration::firstOrCreate([
            'student_id' => $student->id,
            'course_class_id' => $classIoT->id,
        ], [
            'semester_id' => $semester->id,
            'status' => 'registered',
        ]);

        // 10. Hoc phi ky 1 cua sinh vien (9 tin chi * 450.000 = 4.050.000 VND)
        Tuition::firstOrCreate([
            'student_id' => $student->id,
            'semester_id' => $semester->id,
        ], [
            'total_credits' => 9,
            'total_amount' => 4050000.00,
            'paid_amount' => 0.00,
            'status' => 'unpaid',
        ]);
    }
}
