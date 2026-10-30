<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class ScheduleException
 * 
 * @property int $id
 * @property uuid $schedule_exceptions_id
 * @property int $school_id
 * @property int $schedule_id
 * @property Carbon $exception_date
 * @property string $exception_type
 * @property Carbon|null $new_date
 * @property time without time zone|null $new_start_time
 * @property time without time zone|null $new_end_time
 * @property int|null $new_room_id
 * @property int|null $substitute_teacher_id
 * @property string|null $reason
 * @property string $status
 * @property int|null $approved_by
 * @property Carbon|null $approved_at
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Schedule $schedule
 * @property Room|null $room
 * @property Teacher|null $teacher
 * @property User|null $user
 *
 * @package App\Models
 */
class ScheduleException extends Model
{
	protected $table = 'schedule_exceptions';

	protected $casts = [
		'schedule_exceptions_id' => 'string',
		'school_id' => 'int',
		'schedule_id' => 'int',
		'exception_date' => 'datetime',
		'new_date' => 'datetime',
		'new_start_time' => 'string',
		'new_end_time' => 'string',
		'new_room_id' => 'int',
		'substitute_teacher_id' => 'int',
		'approved_by' => 'int',
		'approved_at' => 'datetime',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'schedule_exceptions_id',
		'school_id',
		'schedule_id',
		'exception_date',
		'exception_type',
		'new_date',
		'new_start_time',
		'new_end_time',
		'new_room_id',
		'substitute_teacher_id',
		'reason',
		'status',
		'approved_by',
		'approved_at',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function schedule()
	{
		return $this->belongsTo(Schedule::class);
	}

	public function room()
	{
		return $this->belongsTo(Room::class, 'new_room_id');
	}

	public function teacher()
	{
		return $this->belongsTo(Teacher::class, 'substitute_teacher_id');
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}
}
