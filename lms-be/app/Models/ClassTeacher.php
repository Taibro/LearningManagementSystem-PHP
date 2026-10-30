<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class ClassTeacher
 * 
 * @property int $id
 * @property uuid $class_teacher_id
 * @property int $school_id
 * @property int $class_id
 * @property int $teacher_id
 * @property string $role
 * @property int $assigned_periods
 * @property string|null $note
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Class $class
 * @property Teacher $teacher
 * @property User|null $user
 *
 * @package App\Models
 */
class ClassTeacher extends Model
{
	protected $table = 'class_teacher';

	protected $casts = [
		'class_teacher_id' => 'uuid',
		'school_id' => 'int',
		'class_id' => 'int',
		'teacher_id' => 'int',
		'assigned_periods' => 'int',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'class_teacher_id',
		'school_id',
		'class_id',
		'teacher_id',
		'role',
		'assigned_periods',
		'note',
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

	public function teacher()
	{
		return $this->belongsTo(Teacher::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}
}
