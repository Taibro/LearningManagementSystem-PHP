<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class SalaryConfig
 * 
 * @property int $id
 * @property uuid $salary_config_id
 * @property string $qualification_code
 * @property string $qualification_name
 * @property float $price_per_period
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * 
 * @property Collection|TeacherSalarySheet[] $teacher_salary_sheets
 *
 * @package App\Models
 */
class SalaryConfig extends Model
{
	protected $table = 'salary_config';

	protected $casts = [
		'salary_config_id' => 'string',
		'price_per_period' => 'float'
	];

	protected $fillable = [
		'salary_config_id',
		'qualification_code',
		'qualification_name',
		'price_per_period'
	];

	public function teacher_salary_sheets()
	{
		return $this->hasMany(TeacherSalarySheet::class);
	}
}
