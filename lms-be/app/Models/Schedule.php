<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Schedule
 * 
 * @property int $id
 * @property uuid $schedules_id
 * @property int $school_id
 * @property int $class_id
 * @property int $room_id
 * @property int $day_of_week
 * @property int $start_period
 * @property int $end_period
 * @property time without time zone $start_time
 * @property time without time zone $end_time
 * @property Carbon $effective_from
 * @property Carbon $effective_to
 * @property string $session_type
 * @property string|null $notes
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Class $class
 * @property Room $room
 * @property User|null $user
 * @property Collection|ScheduleException[] $schedule_exceptions
 * @property Collection|AttendanceRecord[] $attendance_records
 *
 * @package App\Models
 */
class Schedule extends Model
{
	protected $table = 'schedules';

	protected $casts = [
		'schedules_id' => 'uuid',
		'school_id' => 'int',
		'class_id' => 'int',
		'room_id' => 'int',
		'day_of_week' => 'int',
		'start_period' => 'int',
		'end_period' => 'int',
		'start_time' => 'time without time zone',
		'end_time' => 'time without time zone',
		'effective_from' => 'datetime',
		'effective_to' => 'datetime',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'schedules_id',
		'school_id',
		'class_id',
		'room_id',
		'day_of_week',
		'start_period',
		'end_period',
		'start_time',
		'end_time',
		'effective_from',
		'effective_to',
		'session_type',
		'notes',
		'is_active',
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

	public function room()
	{
		return $this->belongsTo(Room::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function schedule_exceptions()
	{
		return $this->hasMany(ScheduleException::class);
	}

	public function attendance_records()
	{
		return $this->hasMany(AttendanceRecord::class);
	}
}
