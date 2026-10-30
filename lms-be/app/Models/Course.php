<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Course
 * 
 * @property int $id
 * @property uuid $courses_id
 * @property int $school_id
 * @property int|null $department_id
 * @property string $code
 * @property string $name
 * @property int $credits
 * @property int $total_periods
 * @property int $theory_periods
 * @property int $practice_periods
 * @property float $price_per_credit
 * @property string|null $description
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Department|null $department
 * @property User|null $user
 * @property Collection|Class[] $classes
 *
 * @package App\Models
 */
class Course extends Model
{
	protected $table = 'courses';

	protected $casts = [
		'courses_id' => 'uuid',
		'school_id' => 'int',
		'department_id' => 'int',
		'credits' => 'int',
		'total_periods' => 'int',
		'theory_periods' => 'int',
		'practice_periods' => 'int',
		'price_per_credit' => 'float',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'courses_id',
		'school_id',
		'department_id',
		'code',
		'name',
		'credits',
		'total_periods',
		'theory_periods',
		'practice_periods',
		'price_per_credit',
		'description',
		'is_active',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function department()
	{
		return $this->belongsTo(Department::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function classes()
	{
		return $this->hasMany(Class::class);
	}
}
