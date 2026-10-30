<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Semester
 * 
 * @property int $id
 * @property uuid $semesters_id
 * @property int $school_id
 * @property int $academic_year_id
 * @property string $code
 * @property string $name
 * @property Carbon $start_date
 * @property Carbon $end_date
 * @property bool $is_current
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property AcademicYear $academic_year
 * @property User|null $user
 * @property Collection|Class[] $classes
 * @property Collection|TuitionInvoice[] $tuition_invoices
 * @property Collection|Student[] $students
 * @property Collection|TeacherDeclaration[] $teacher_declarations
 * @property Collection|TeacherSalarySheet[] $teacher_salary_sheets
 *
 * @package App\Models
 */
class Semester extends Model
{
	protected $table = 'semesters';

	protected $casts = [
		'semesters_id' => 'uuid',
		'school_id' => 'int',
		'academic_year_id' => 'int',
		'start_date' => 'datetime',
		'end_date' => 'datetime',
		'is_current' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'semesters_id',
		'school_id',
		'academic_year_id',
		'code',
		'name',
		'start_date',
		'end_date',
		'is_current',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function academic_year()
	{
		return $this->belongsTo(AcademicYear::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function classes()
	{
		return $this->hasMany(Class::class);
	}

	public function tuition_invoices()
	{
		return $this->hasMany(TuitionInvoice::class);
	}

	public function students()
	{
		return $this->belongsToMany(Student::class, 'student_semester_summaries')
					->withPivot('id', 'student_semester_summaries_id', 'school_id', 'gpa_10', 'gpa_4', 'credits_earned', 'conduct_score', 'conduct_rank', 'academic_rank', 'is_eligible_scholarship', 'scholarship_type')
					->withTimestamps();
	}

	public function teacher_declarations()
	{
		return $this->hasMany(TeacherDeclaration::class);
	}

	public function teacher_salary_sheets()
	{
		return $this->hasMany(TeacherSalarySheet::class);
	}
}
