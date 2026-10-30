<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SchoolBranch
 * 
 * @property int $id
 * @property uuid $school_branches_id
 * @property int $school_id
 * @property string $code
 * @property string $name
 * @property string|null $address
 * @property string|null $phone
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property User|null $user
 * @property Collection|Room[] $rooms
 *
 * @package App\Models
 */
class SchoolBranch extends Model
{
	protected $table = 'school_branches';

	protected $casts = [
		'school_branches_id' => 'uuid',
		'school_id' => 'int',
		'is_active' => 'bool',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'school_branches_id',
		'school_id',
		'code',
		'name',
		'address',
		'phone',
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
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function rooms()
	{
		return $this->hasMany(Room::class, 'branch_id');
	}
}
