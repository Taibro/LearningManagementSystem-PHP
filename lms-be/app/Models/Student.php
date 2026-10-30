<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Student
 * 
 * @property int $id
 * @property uuid $students_id
 * @property int $school_id
 * @property int $user_id
 * @property int|null $department_id
 * @property string $student_code
 * @property Carbon|null $date_of_birth
 * @property string|null $gender
 * @property string|null $address
 * @property Carbon|null $enrollment_date
 * @property string|null $placeofbirth
 * @property string|null $population
 * @property string|null $major
 * @property string|null $degreelevel
 * @property string|null $trainingtype
 * @property string|null $administrativeclass
 * @property string $enrollment_status
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property User|null $user
 * @property Department|null $department
 * @property Collection|Enrollment[] $enrollments
 * @property Collection|AttendanceRecord[] $attendance_records
 * @property Collection|TuitionInvoice[] $tuition_invoices
 * @property Collection|Semester[] $semesters
 * @property Collection|TeacherEvaluation[] $teacher_evaluations
 *
 * @package App\Models
 */
class Student extends Model
{
	protected $table = 'students';

	protected $casts = [
		'students_id' => 'uuid',
		'school_id' => 'int',
		'user_id' => 'int',
		'department_id' => 'int',
		'date_of_birth' => 'datetime',
		'enrollment_date' => 'datetime',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'students_id',
		'school_id',
		'user_id',
		'department_id',
		'student_code',
		'date_of_birth',
		'gender',
		'address',
		'enrollment_date',
		'placeofbirth',
		'population',
		'major',
		'degreelevel',
		'trainingtype',
		'administrativeclass',
		'enrollment_status',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function department()
	{
		return $this->belongsTo(Department::class);
	}

	public function enrollments()
	{
		return $this->hasMany(Enrollment::class);
	}

	public function attendance_records()
	{
		return $this->hasMany(AttendanceRecord::class);
	}

	public function tuition_invoices()
	{
		return $this->hasMany(TuitionInvoice::class);
	}

	public function semesters()
	{
		return $this->belongsToMany(Semester::class, 'student_semester_summaries')
					->withPivot('id', 'student_semester_summaries_id', 'school_id', 'gpa_10', 'gpa_4', 'credits_earned', 'conduct_score', 'conduct_rank', 'academic_rank', 'is_eligible_scholarship', 'scholarship_type')
					->withTimestamps();
	}

	public function teacher_evaluations()
	{
		return $this->hasMany(TeacherEvaluation::class);
	}
}
