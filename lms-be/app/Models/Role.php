<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Role
 * 
 * @property int $id
 * @property uuid $role_id
 * @property string $name
 * @property string|null $description
 * @property bool $is_system_role
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property Collection|User[] $users
 *
 * @package App\Models
 */
class Role extends Model
{
	protected $table = 'role';

	protected $casts = [
		'role_id' => 'uuid',
		'is_system_role' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'role_id',
		'name',
		'description',
		'is_system_role',
		'created_by',
		'updated_by'
	];

	public function users()
	{
		return $this->belongsToMany(User::class, 'user_roles', 'role_id', 'updated_by')
					->withPivot('id', 'user_roles_id', 'school_id', 'user_id', 'department_id', 'granted_by', 'granted_at', 'expires_at', 'is_active', 'created_by')
					->withTimestamps();
	}
}
