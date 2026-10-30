<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class StudentSemesterSummary
 * 
 * @property int $id
 * @property uuid $student_semester_summaries_id
 * @property int $school_id
 * @property int $student_id
 * @property int $semester_id
 * @property float|null $gpa_10
 * @property float|null $gpa_4
 * @property int $credits_earned
 * @property int|null $conduct_score
 * @property string|null $conduct_rank
 * @property string|null $academic_rank
 * @property bool $is_eligible_scholarship
 * @property string|null $scholarship_type
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property School $school
 * @property Student $student
 * @property Semester $semester
 *
 * @package App\Models
 */
class StudentSemesterSummary extends Model
{
	protected $table = 'student_semester_summaries';

	protected $casts = [
		'student_semester_summaries_id' => 'string',
		'school_id' => 'int',
		'student_id' => 'int',
		'semester_id' => 'int',
		'gpa_10' => 'float',
		'gpa_4' => 'float',
		'credits_earned' => 'int',
		'conduct_score' => 'int',
		'is_eligible_scholarship' => 'bool'
	];

	protected $fillable = [
		'student_semester_summaries_id',
		'school_id',
		'student_id',
		'semester_id',
		'gpa_10',
		'gpa_4',
		'credits_earned',
		'conduct_score',
		'conduct_rank',
		'academic_rank',
		'is_eligible_scholarship',
		'scholarship_type'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function student()
	{
		return $this->belongsTo(Student::class);
	}

	public function semester()
	{
		return $this->belongsTo(Semester::class);
	}
}
