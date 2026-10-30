<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class UserRole
 * 
 * @property int $id
 * @property uuid $user_roles_id
 * @property int $school_id
 * @property int $user_id
 * @property int $role_id
 * @property int|null $department_id
 * @property int|null $granted_by
 * @property Carbon $granted_at
 * @property Carbon|null $expires_at
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property User|null $user
 * @property Role $role
 * @property Department|null $department
 *
 * @package App\Models
 */
class UserRole extends Model
{
	protected $table = 'user_roles';

	protected $casts = [
		'user_roles_id' => 'string',
		'school_id' => 'int',
		'user_id' => 'int',
		'role_id' => 'int',
		'department_id' => 'int',
		'granted_by' => 'int',
		'granted_at' => 'datetime',
		'expires_at' => 'datetime',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'user_roles_id',
		'school_id',
		'user_id',
		'role_id',
		'department_id',
		'granted_by',
		'granted_at',
		'expires_at',
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
		return $this->belongsTo(User::class, 'user_id');
	}

	public function role()
	{
		return $this->belongsTo(Role::class);
	}

	public function department()
	{
		return $this->belongsTo(Department::class);
	}
}
