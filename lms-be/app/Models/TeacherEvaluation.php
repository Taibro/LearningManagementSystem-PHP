<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class TeacherEvaluation
 * 
 * @property int $id
 * @property uuid $teacher_evaluations_id
 * @property int $school_id
 * @property int $class_id
 * @property int $student_id
 * @property int $criteria_1
 * @property int $criteria_2
 * @property int $criteria_3
 * @property int $criteria_4
 * @property int $criteria_5
 * @property float $average_rating
 * @property string|null $comments
 * @property Carbon $created_at
 * 
 * @property School $school
 * @property Class $class
 * @property Student $student
 *
 * @package App\Models
 */
class TeacherEvaluation extends Model
{
	protected $table = 'teacher_evaluations';
	public $timestamps = false;

	protected $casts = [
		'teacher_evaluations_id' => 'string',
		'school_id' => 'int',
		'class_id' => 'int',
		'student_id' => 'int',
		'criteria_1' => 'int',
		'criteria_2' => 'int',
		'criteria_3' => 'int',
		'criteria_4' => 'int',
		'criteria_5' => 'int',
		'average_rating' => 'float'
	];

	protected $fillable = [
		'teacher_evaluations_id',
		'school_id',
		'class_id',
		'student_id',
		'criteria_1',
		'criteria_2',
		'criteria_3',
		'criteria_4',
		'criteria_5',
		'average_rating',
		'comments'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function class()
	{
		return $this->belongsTo(CourseClass::class, 'class_id');
	}

	public function student()
	{
		return $this->belongsTo(Student::class);
	}
}
