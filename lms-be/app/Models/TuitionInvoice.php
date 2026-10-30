<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class TuitionInvoice
 * 
 * @property int $id
 * @property uuid $tuition_invoices_id
 * @property int $school_id
 * @property int $student_id
 * @property int $semester_id
 * @property string $invoice_code
 * @property int $total_credits
 * @property float $total_amount
 * @property float $paid_amount
 * @property Carbon $due_date
 * @property string $status
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Student $student
 * @property Semester $semester
 * @property Collection|TuitionPayment[] $tuition_payments
 *
 * @package App\Models
 */
class TuitionInvoice extends Model
{
	protected $table = 'tuition_invoices';

	protected $casts = [
		'tuition_invoices_id' => 'string',
		'school_id' => 'int',
		'student_id' => 'int',
		'semester_id' => 'int',
		'total_credits' => 'int',
		'total_amount' => 'float',
		'paid_amount' => 'float',
		'due_date' => 'datetime',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'tuition_invoices_id',
		'school_id',
		'student_id',
		'semester_id',
		'invoice_code',
		'total_credits',
		'total_amount',
		'paid_amount',
		'due_date',
		'status',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function student()
	{
		return $this->belongsTo(Student::class);
	}

	public function semester()
	{
		return $this->belongsTo(Semester::class);
	}

	public function tuition_payments()
	{
		return $this->hasMany(TuitionPayment::class, 'invoice_id');
	}
}
