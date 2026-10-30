<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Enrollment
 * 
 * @property int $id
 * @property uuid $enrollments_id
 * @property int $school_id
 * @property int $class_id
 * @property int $student_id
 * @property Carbon $enrolled_at
 * @property string $status
 * @property float|null $attendance_score
 * @property float|null $regular_score1
 * @property float|null $regular_score2
 * @property float|null $regular_score3
 * @property float|null $midterm_score
 * @property float|null $final_score
 * @property float|null $total_score
 * @property string|null $grade_letter
 * @property float|null $grade_point_4
 * @property bool|null $is_passed
 * @property string|null $notes
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Class $class
 * @property Student $student
 * @property User|null $user
 *
 * @package App\Models
 */
class Enrollment extends Model
{
	protected $table = 'enrollments';

	protected $casts = [
		'enrollments_id' => 'uuid',
		'school_id' => 'int',
		'class_id' => 'int',
		'student_id' => 'int',
		'enrolled_at' => 'datetime',
		'attendance_score' => 'float',
		'regular_score1' => 'float',
		'regular_score2' => 'float',
		'regular_score3' => 'float',
		'midterm_score' => 'float',
		'final_score' => 'float',
		'total_score' => 'float',
		'grade_point_4' => 'float',
		'is_passed' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'enrollments_id',
		'school_id',
		'class_id',
		'student_id',
		'enrolled_at',
		'status',
		'attendance_score',
		'regular_score1',
		'regular_score2',
		'regular_score3',
		'midterm_score',
		'final_score',
		'total_score',
		'grade_letter',
		'grade_point_4',
		'is_passed',
		'notes',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function class()
	{
		return $this->belongsTo(Class::class);
	}

	public function student()
	{
		return $this->belongsTo(Student::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}
}
