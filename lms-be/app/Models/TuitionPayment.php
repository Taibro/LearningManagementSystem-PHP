<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class TuitionPayment
 * 
 * @property int $id
 * @property string $tuition_payments_id
 * @property int $school_id
 * @property int $invoice_id
 * @property string $transaction_code
 * @property float $amount_paid
 * @property string $payment_method
 * @property Carbon $payment_date
 * @property string $status
 * @property array<int, array<string, mixed>>|null $course_data
 * @property Carbon|null $expires_at
 * @property string|null $notes
 * @property Carbon $created_at
 * 
 * @property School $school
 * @property TuitionInvoice $tuition_invoice
 *
 * @package App\Models
 */
class TuitionPayment extends Model
{
	protected $table = 'tuition_payments';
	public $timestamps = false;

	protected $casts = [
		'tuition_payments_id' => 'string',
		'school_id' => 'int',
		'invoice_id' => 'int',
		'amount_paid' => 'float',
		'payment_date' => 'datetime',
		'course_data' => 'array',
		'expires_at' => 'datetime',
	];

	protected $fillable = [
		'tuition_payments_id',
		'school_id',
		'invoice_id',
		'transaction_code',
		'amount_paid',
		'payment_method',
		'payment_date',
		'status',
		'course_data',
		'expires_at',
		'notes'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function tuition_invoice()
	{
		return $this->belongsTo(TuitionInvoice::class, 'invoice_id');
	}
}
