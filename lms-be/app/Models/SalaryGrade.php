<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SalaryGrade
 * 
 * @property int $id
 * @property uuid $salary_grade_id
 * @property string $grade_code
 * @property int $step_number
 * @property float $coefficient
 * @property float $base_salary
 * @property float $seniority_pct
 * @property float $position_allowance
 * @property Carbon $effective_from
 * @property Carbon|null $effective_to
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property Collection|TeacherSalarySheet[] $teacher_salary_sheets
 *
 * @package App\Models
 */
class SalaryGrade extends Model
{
	protected $table = 'salary_grade';

	protected $casts = [
		'salary_grade_id' => 'uuid',
		'step_number' => 'int',
		'coefficient' => 'float',
		'base_salary' => 'float',
		'seniority_pct' => 'float',
		'position_allowance' => 'float',
		'effective_from' => 'datetime',
		'effective_to' => 'datetime'
	];

	protected $fillable = [
		'salary_grade_id',
		'grade_code',
		'step_number',
		'coefficient',
		'base_salary',
		'seniority_pct',
		'position_allowance',
		'effective_from',
		'effective_to'
	];

	public function teacher_salary_sheets()
	{
		return $this->hasMany(TeacherSalarySheet::class);
	}
}
