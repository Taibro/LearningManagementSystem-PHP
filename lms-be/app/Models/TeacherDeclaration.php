<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class TeacherDeclaration
 * 
 * @property int $id
 * @property uuid $teacher_declarations_id
 * @property int $school_id
 * @property int $teacher_id
 * @property int $semester_id
 * @property string $declaration_type
 * @property string $title
 * @property string|null $description
 * @property float $claimed_hours
 * @property float|null $approved_hours
 * @property string|null $evidence_url
 * @property string $status
 * @property int|null $approved_by
 * @property Carbon|null $approved_at
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property School $school
 * @property Teacher $teacher
 * @property Semester $semester
 * @property User|null $user
 *
 * @package App\Models
 */
class TeacherDeclaration extends Model
{
	protected $table = 'teacher_declarations';

	protected $casts = [
		'teacher_declarations_id' => 'uuid',
		'school_id' => 'int',
		'teacher_id' => 'int',
		'semester_id' => 'int',
		'claimed_hours' => 'float',
		'approved_hours' => 'float',
		'approved_by' => 'int',
		'approved_at' => 'datetime'
	];

	protected $fillable = [
		'teacher_declarations_id',
		'school_id',
		'teacher_id',
		'semester_id',
		'declaration_type',
		'title',
		'description',
		'claimed_hours',
		'approved_hours',
		'evidence_url',
		'status',
		'approved_by',
		'approved_at'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function teacher()
	{
		return $this->belongsTo(Teacher::class);
	}

	public function semester()
	{
		return $this->belongsTo(Semester::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'approved_by');
	}
}
