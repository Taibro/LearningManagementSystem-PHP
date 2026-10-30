<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class AuditLog
 * 
 * @property int $id
 * @property uuid $audit_logs_id
 * @property int|null $school_id
 * @property int $user_id
 * @property string $action
 * @property string $entity_name
 * @property int|null $entity_id
 * @property string|null $old_values
 * @property string|null $new_values
 * @property string|null $ip_address
 * @property Carbon $created_at
 * 
 * @property School|null $school
 * @property User $user
 *
 * @package App\Models
 */
class AuditLog extends Model
{
	protected $table = 'audit_logs';
	public $timestamps = false;

	protected $casts = [
		'audit_logs_id' => 'string',
		'school_id' => 'int',
		'user_id' => 'int',
		'entity_id' => 'int',
		'old_values' => 'array',
		'new_values' => 'array'
	];

	protected $fillable = [
		'audit_logs_id',
		'school_id',
		'user_id',
		'action',
		'entity_name',
		'entity_id',
		'old_values',
		'new_values',
		'ip_address'
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
