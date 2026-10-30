<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SaasPlan
 * 
 * @property int $id
 * @property uuid $saas_plans_id
 * @property string $code
 * @property string $name
 * @property string|null $description
 * @property float $monthly_price
 * @property float $yearly_price
 * @property int $max_students
 * @property int $max_teachers
 * @property int $max_storage_gb
 * @property string|null $features
 * @property bool $is_active
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property Collection|SaasSubscription[] $saas_subscriptions
 *
 * @package App\Models
 */
class SaasPlan extends Model
{
	protected $table = 'saas_plans';

	protected $casts = [
		'saas_plans_id' => 'string',
		'monthly_price' => 'float',
		'yearly_price' => 'float',
		'max_students' => 'int',
		'max_teachers' => 'int',
		'max_storage_gb' => 'int',
		'features' => 'array',
		'is_active' => 'bool'
	];

	protected $fillable = [
		'saas_plans_id',
		'code',
		'name',
		'description',
		'monthly_price',
		'yearly_price',
		'max_students',
		'max_teachers',
		'max_storage_gb',
		'features',
		'is_active'
	];

	public function saas_subscriptions()
	{
		return $this->hasMany(SaasSubscription::class, 'plan_id');
	}
}
