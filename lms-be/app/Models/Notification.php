<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class Notification
 * 
 * @property int $id
 * @property uuid $notifications_id
 * @property int $school_id
 * @property int $recipient_user_id
 * @property string $title
 * @property string $message
 * @property string $notification_type
 * @property string|null $reference_type
 * @property int|null $reference_id
 * @property bool $is_read
 * @property Carbon|null $read_at
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property User|null $user
 *
 * @package App\Models
 */
class Notification extends Model
{
	protected $table = 'notifications';

	protected $casts = [
		'notifications_id' => 'uuid',
		'school_id' => 'int',
		'recipient_user_id' => 'int',
		'reference_id' => 'int',
		'is_read' => 'bool',
		'read_at' => 'datetime',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'notifications_id',
		'school_id',
		'recipient_user_id',
		'title',
		'message',
		'notification_type',
		'reference_type',
		'reference_id',
		'is_read',
		'read_at',
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
}
