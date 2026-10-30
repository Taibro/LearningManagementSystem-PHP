<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Department
 * 
 * @property int $id
 * @property uuid $departments_id
 * @property int $school_id
 * @property string $code
 * @property string $name
 * @property string|null $description
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property User|null $user
 * @property Collection|UserRole[] $user_roles
 * @property Collection|Teacher[] $teachers
 * @property Collection|Student[] $students
 * @property Collection|Course[] $courses
 *
 * @package App\Models
 */
class Department extends Model
{
	protected $table = 'departments';

	protected $casts = [
		'departments_id' => 'uuid',
		'school_id' => 'int',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'departments_id',
		'school_id',
		'code',
		'name',
		'description',
		'is_active',
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
}
