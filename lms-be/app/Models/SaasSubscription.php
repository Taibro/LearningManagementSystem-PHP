<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SaasSubscription
 * 
 * @property int $id
 * @property uuid $saas_subscriptions_id
 * @property int $school_id
 * @property int $plan_id
 * @property string $billing_cycle
 * @property Carbon $start_date
 * @property Carbon $end_date
 * @property string $status
 * @property bool $auto_renew
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property School $school
 * @property SaasPlan $saas_plan
 * @property Collection|SaasInvoice[] $saas_invoices
 *
 * @package App\Models
 */
class SaasSubscription extends Model
{
	protected $table = 'saas_subscriptions';

	protected $casts = [
		'saas_subscriptions_id' => 'string',
		'school_id' => 'int',
		'plan_id' => 'int',
		'start_date' => 'datetime',
		'end_date' => 'datetime',
		'auto_renew' => 'bool'
	];

	protected $fillable = [
		'saas_subscriptions_id',
		'school_id',
		'plan_id',
		'billing_cycle',
		'start_date',
		'end_date',
		'status',
		'auto_renew'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function saas_plan()
	{
		return $this->belongsTo(SaasPlan::class, 'plan_id');
	}

	public function saas_invoices()
	{
		return $this->hasMany(SaasInvoice::class, 'subscription_id');
	}
}
