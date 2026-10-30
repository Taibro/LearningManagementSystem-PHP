<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Room
 * 
 * @property int $id
 * @property uuid $rooms_id
 * @property int $school_id
 * @property int|null $branch_id
 * @property string $code
 * @property string $name
 * @property string|null $building
 * @property int|null $floor
 * @property int $capacity
 * @property string $room_type
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property SchoolBranch|null $school_branch
 * @property User|null $user
 * @property Collection|Schedule[] $schedules
 * @property Collection|ScheduleException[] $schedule_exceptions
 *
 * @package App\Models
 */
class Room extends Model
{
	protected $table = 'rooms';

	protected $casts = [
		'rooms_id' => 'uuid',
		'school_id' => 'int',
		'branch_id' => 'int',
		'floor' => 'int',
		'capacity' => 'int',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'rooms_id',
		'school_id',
		'branch_id',
		'code',
		'name',
		'building',
		'floor',
		'capacity',
		'room_type',
		'is_active',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function school_branch()
	{
		return $this->belongsTo(SchoolBranch::class, 'branch_id');
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function schedules()
	{
		return $this->hasMany(Schedule::class);
	}

	public function schedule_exceptions()
	{
		return $this->hasMany(ScheduleException::class, 'new_room_id');
	}
}
