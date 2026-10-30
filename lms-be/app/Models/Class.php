<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Class
 * 
 * @property int $id
 * @property uuid $classes_id
 * @property int $school_id
 * @property int $semester_id
 * @property int $course_id
 * @property int $teacher_id
 * @property string $code
 * @property string|null $name
 * @property int $max_students
 * @property string $status
 * @property string|null $notes
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Semester $semester
 * @property Course $course
 * @property Teacher $teacher
 * @property User|null $user
 * @property Collection|Schedule[] $schedules
 * @property Collection|Enrollment[] $enrollments
 * @property Collection|ClassMaterial[] $class_materials
 * @property Collection|TeacherEvaluation[] $teacher_evaluations
 * @property Collection|Teacher[] $teachers
 * @property Collection|TeacherSalaryDetail[] $teacher_salary_details
 *
 * @package App\Models
 */
class Class extends Model
{
	protected $table = 'classes';

	protected $casts = [
		'classes_id' => 'uuid',
		'school_id' => 'int',
		'semester_id' => 'int',
		'course_id' => 'int',
		'teacher_id' => 'int',
		'max_students' => 'int',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'classes_id',
		'school_id',
		'semester_id',
		'course_id',
		'teacher_id',
		'code',
		'name',
		'max_students',
		'status',
		'notes',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function semester()
	{
		return $this->belongsTo(Semester::class);
	}

	public function course()
	{
		return $this->belongsTo(Course::class);
	}

	public function teacher()
	{
		return $this->belongsTo(Teacher::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function schedules()
	{
		return $this->hasMany(Schedule::class);
	}

	public function enrollments()
	{
		return $this->hasMany(Enrollment::class);
	}

	public function class_materials()
	{
		return $this->hasMany(ClassMaterial::class);
	}

	public function teacher_evaluations()
	{
		return $this->hasMany(TeacherEvaluation::class);
	}

	public function teachers()
	{
		return $this->belongsToMany(Teacher::class)
					->withPivot('id', 'class_teacher_id', 'school_id', 'role', 'assigned_periods', 'note', 'created_by', 'updated_by')
					->withTimestamps();
	}

	public function teacher_salary_details()
	{
		return $this->hasMany(TeacherSalaryDetail::class);
	}
}
