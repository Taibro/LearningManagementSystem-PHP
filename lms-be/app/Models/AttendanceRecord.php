<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class AttendanceRecord
 * 
 * @property int $id
 * @property uuid $attendance_records_id
 * @property int $school_id
 * @property int $schedule_id
 * @property int $student_id
 * @property Carbon $attendance_date
 * @property string $status
 * @property string|null $note
 * @property int|null $recorded_by
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Schedule $schedule
 * @property Student $student
 * @property User|null $user
 *
 * @package App\Models
 */
class AttendanceRecord extends Model
{
	protected $table = 'attendance_records';

	protected $casts = [
		'attendance_records_id' => 'uuid',
		'school_id' => 'int',
		'schedule_id' => 'int',
		'student_id' => 'int',
		'attendance_date' => 'datetime',
		'recorded_by' => 'int',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'attendance_records_id',
		'school_id',
		'schedule_id',
		'student_id',
		'attendance_date',
		'status',
		'note',
		'recorded_by',
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

	public function student()
	{
		return $this->belongsTo(Student::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}
}
