<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Teacher
 * 
 * @property int $id
 * @property uuid $teachers_id
 * @property int $school_id
 * @property int $user_id
 * @property int|null $department_id
 * @property string $teacher_code
 * @property string|null $specialization
 * @property string|null $qualification
 * @property Carbon|null $hire_date
 * @property string $status
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property User|null $user
 * @property Department|null $department
 * @property Collection|Class[] $classes
 * @property Collection|ScheduleException[] $schedule_exceptions
 * @property Collection|TeacherDeclaration[] $teacher_declarations
 * @property Collection|TeacherSalarySheet[] $teacher_salary_sheets
 *
 * @package App\Models
 */
class Teacher extends Model
{
	protected $table = 'teachers';

	protected $casts = [
		'teachers_id' => 'string',
		'school_id' => 'int',
		'user_id' => 'int',
		'department_id' => 'int',
		'hire_date' => 'datetime',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'teachers_id',
		'school_id',
		'user_id',
		'department_id',
		'teacher_code',
		'specialization',
		'qualification',
		'hire_date',
		'status',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'user_id');
	}

	public function department()
	{
		return $this->belongsTo(Department::class);
	}

	public function classes()
	{
		return $this->belongsToMany(CourseClass::class, 'class_teacher', 'teacher_id', 'class_id')
					->withPivot('id', 'class_teacher_id', 'school_id', 'role', 'assigned_periods', 'note', 'created_by', 'updated_by')
					->withTimestamps();
	}

	public function schedule_exceptions()
	{
		return $this->hasMany(ScheduleException::class, 'substitute_teacher_id');
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
