<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;

/**
 * Class TeacherSalaryDetail
 * 
 * @property int $id
 * @property uuid $teacher_salary_detail_id
 * @property int $school_id
 * @property int $salary_sheet_id
 * @property int $class_id
 * @property int $periods_assigned
 * @property int $periods_taught
 * @property int $periods_makeup
 * @property int $periods_substitute
 * @property float $class_coeff
 * @property float $subject_coeff
 * @property float $converted_periods
 * @property float $price_per_period
 * @property float $amount
 * @property string|null $note
 * @property Carbon $created_at
 * 
 * @property School $school
 * @property TeacherSalarySheet $teacher_salary_sheet
 * @property Class $class
 *
 * @package App\Models
 */
class TeacherSalaryDetail extends Model
{
	protected $table = 'teacher_salary_detail';
	public $timestamps = false;

	protected $casts = [
		'teacher_salary_detail_id' => 'string',
		'school_id' => 'int',
		'salary_sheet_id' => 'int',
		'class_id' => 'int',
		'periods_assigned' => 'int',
		'periods_taught' => 'int',
		'periods_makeup' => 'int',
		'periods_substitute' => 'int',
		'class_coeff' => 'float',
		'subject_coeff' => 'float',
		'converted_periods' => 'float',
		'price_per_period' => 'float',
		'amount' => 'float'
	];

	protected $fillable = [
		'teacher_salary_detail_id',
		'school_id',
		'salary_sheet_id',
		'class_id',
		'periods_assigned',
		'periods_taught',
		'periods_makeup',
		'periods_substitute',
		'class_coeff',
		'subject_coeff',
		'converted_periods',
		'price_per_period',
		'amount',
		'note'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function teacher_salary_sheet()
	{
		return $this->belongsTo(TeacherSalarySheet::class, 'salary_sheet_id');
	}

	public function class()
	{
		return $this->belongsTo(CourseClass::class, 'class_id');
	}
}
