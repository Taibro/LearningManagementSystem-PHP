<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class School
 * 
 * @property int $id
 * @property uuid $school_id
 * @property string $code
 * @property string $name
 * @property string|null $domain
 * @property string|null $address
 * @property string|null $phone
 * @property string|null $email
 * @property string|null $logo_url
 * @property string $subscription_status
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property User|null $user
 * @property Collection|SchoolBranch[] $school_branches
 * @property Collection|AcademicYear[] $academic_years
 * @property Collection|Semester[] $semesters
 * @property Collection|Department[] $departments
 * @property Collection|User[] $users
 * @property Collection|UserRole[] $user_roles
 * @property Collection|Teacher[] $teachers
 * @property Collection|Student[] $students
 * @property Collection|Course[] $courses
 * @property Collection|Room[] $rooms
 * @property Collection|Class[] $classes
 * @property Collection|Schedule[] $schedules
 * @property Collection|ScheduleException[] $schedule_exceptions
 * @property Collection|Enrollment[] $enrollments
 * @property Collection|AttendanceRecord[] $attendance_records
 * @property Collection|Notification[] $notifications
 * @property Collection|TuitionInvoice[] $tuition_invoices
 * @property Collection|TuitionPayment[] $tuition_payments
 * @property Collection|StudentSemesterSummary[] $student_semester_summaries
 * @property Collection|TeacherDeclaration[] $teacher_declarations
 * @property Collection|ClassMaterial[] $class_materials
 * @property Collection|TeacherEvaluation[] $teacher_evaluations
 * @property Collection|ClassTeacher[] $class_teachers
 * @property Collection|TeacherSalarySheet[] $teacher_salary_sheets
 * @property Collection|TeacherSalaryDetail[] $teacher_salary_details
 * @property Collection|SaasSubscription[] $saas_subscriptions
 * @property Collection|SaasInvoice[] $saas_invoices
 * @property Collection|AuditLog[] $audit_logs
 * @property Collection|SystemErrorLog[] $system_error_logs
 *
 * @package App\Models
 */
class School extends Model
{
	protected $table = 'schools';

	protected $casts = [
		'school_id' => 'uuid',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'school_id',
		'code',
		'name',
		'domain',
		'address',
		'phone',
		'email',
		'logo_url',
		'subscription_status',
		'is_active',
		'created_by',
		'updated_by'
	];

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function school_branches()
	{
		return $this->hasMany(SchoolBranch::class);
	}

	public function academic_years()
	{
		return $this->hasMany(AcademicYear::class);
	}

	public function semesters()
	{
		return $this->hasMany(Semester::class);
	}

	public function departments()
	{
		return $this->hasMany(Department::class);
	}

	public function users()
	{
		return $this->hasMany(User::class);
	}

	public function user_roles()
	{
		return $this->hasMany(UserRole::class);
	}

	public function teachers()
	{
		return $this->hasMany(Teacher::class);
	}

	public function students()
	{
		return $this->hasMany(Student::class);
	}

	public function courses()
	{
		return $this->hasMany(Course::class);
	}

	public function rooms()
	{
		return $this->hasMany(Room::class);
	}

	public function classes()
	{
		return $this->hasMany(Class::class);
	}

	public function schedules()
	{
		return $this->hasMany(Schedule::class);
	}

	public function schedule_exceptions()
	{
		return $this->hasMany(ScheduleException::class);
	}

	public function enrollments()
	{
		return $this->hasMany(Enrollment::class);
	}

	public function attendance_records()
	{
		return $this->hasMany(AttendanceRecord::class);
	}

	public function notifications()
	{
		return $this->hasMany(Notification::class);
	}

	public function tuition_invoices()
	{
		return $this->hasMany(TuitionInvoice::class);
	}

	public function tuition_payments()
	{
		return $this->hasMany(TuitionPayment::class);
	}

	public function student_semester_summaries()
	{
		return $this->hasMany(StudentSemesterSummary::class);
	}

	public function teacher_declarations()
	{
		return $this->hasMany(TeacherDeclaration::class);
	}

	public function class_materials()
	{
		return $this->hasMany(ClassMaterial::class);
	}

	public function teacher_evaluations()
	{
		return $this->hasMany(TeacherEvaluation::class);
	}

	public function class_teachers()
	{
		return $this->hasMany(ClassTeacher::class);
	}

	public function teacher_salary_sheets()
	{
		return $this->hasMany(TeacherSalarySheet::class);
	}

	public function teacher_salary_details()
	{
		return $this->hasMany(TeacherSalaryDetail::class);
	}

	public function saas_subscriptions()
	{
		return $this->hasMany(SaasSubscription::class);
	}

	public function saas_invoices()
	{
		return $this->hasMany(SaasInvoice::class);
	}

	public function audit_logs()
	{
		return $this->hasMany(AuditLog::class);
	}

	public function system_error_logs()
	{
		return $this->hasMany(SystemErrorLog::class);
	}
}
