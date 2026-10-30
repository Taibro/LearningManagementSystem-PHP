<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class AcademicYear
 * 
 * @property int $id
 * @property uuid $academic_years_id
 * @property int $school_id
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
 * @property User|null $user
 * @property Collection|Semester[] $semesters
 *
 * @package App\Models
 */
class AcademicYear extends Model
{
	protected $table = 'academic_years';

	protected $casts = [
		'academic_years_id' => 'uuid',
		'school_id' => 'int',
		'start_date' => 'datetime',
		'end_date' => 'datetime',
		'is_current' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'academic_years_id',
		'school_id',
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

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function semesters()
	{
		return $this->hasMany(Semester::class);
	}
}
