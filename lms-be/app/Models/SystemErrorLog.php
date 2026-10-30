<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SystemErrorLog
 * 
 * @property int $id
 * @property uuid $system_error_logs_id
 * @property int|null $school_id
 * @property int|null $user_id
 * @property string $error_level
 * @property string $endpoint
 * @property string $request_method
 * @property int $status_code
 * @property string $error_message
 * @property string|null $stack_trace
 * @property string|null $ip_address
 * @property string|null $user_agent
 * @property Carbon $created_at
 * 
 * @property School|null $school
 * @property User|null $user
 *
 * @package App\Models
 */
class SystemErrorLog extends Model
{
	protected $table = 'system_error_logs';
	public $timestamps = false;

	protected $casts = [
		'system_error_logs_id' => 'uuid',
		'school_id' => 'int',
		'user_id' => 'int',
		'status_code' => 'int'
	];

	protected $fillable = [
		'system_error_logs_id',
		'school_id',
		'user_id',
		'error_level',
		'endpoint',
		'request_method',
		'status_code',
		'error_message',
		'stack_trace',
		'ip_address',
		'user_agent'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class);
	}
}
