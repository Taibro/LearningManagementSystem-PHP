<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SaasInvoice
 * 
 * @property int $id
 * @property uuid $saas_invoices_id
 * @property int $school_id
 * @property int $subscription_id
 * @property string $invoice_number
 * @property float $amount
 * @property Carbon $billing_date
 * @property Carbon $due_date
 * @property Carbon|null $paid_at
 * @property string|null $payment_method
 * @property string $status
 * @property string|null $notes
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property School $school
 * @property SaasSubscription $saas_subscription
 *
 * @package App\Models
 */
class SaasInvoice extends Model
{
	protected $table = 'saas_invoices';

	protected $casts = [
		'saas_invoices_id' => 'uuid',
		'school_id' => 'int',
		'subscription_id' => 'int',
		'amount' => 'float',
		'billing_date' => 'datetime',
		'due_date' => 'datetime',
		'paid_at' => 'datetime'
	];

	protected $fillable = [
		'saas_invoices_id',
		'school_id',
		'subscription_id',
		'invoice_number',
		'amount',
		'billing_date',
		'due_date',
		'paid_at',
		'payment_method',
		'status',
		'notes'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function saas_subscription()
	{
		return $this->belongsTo(SaasSubscription::class, 'subscription_id');
	}
}
