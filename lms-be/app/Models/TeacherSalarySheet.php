<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * Class TeacherSalarySheet
 * 
 * @property int $id
 * @property uuid $teacher_salary_sheet_id
 * @property int $school_id
 * @property int $teacher_id
 * @property int $semester_id
 * @property int $month
 * @property int $year
 * @property int|null $salary_grade_id
 * @property int|null $salary_config_id
 * @property float $coefficient_salary
 * @property float $seniority_allowance
 * @property float $position_allowance
 * @property int $total_periods_taught
 * @property float $teaching_pay
 * @property float $research_bonus
 * @property float $other_allowance
 * @property float $deductions
 * @property float $total_net_salary
 * @property string $status
 * @property int|null $confirmed_by
 * @property Carbon|null $confirmed_at
 * @property Carbon|null $paid_at
 * @property string|null $notes
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * 
 * @property School $school
 * @property Teacher $teacher
 * @property Semester $semester
 * @property SalaryGrade|null $salary_grade
 * @property SalaryConfig|null $salary_config
 * @property User|null $user
 * @property Collection|TeacherSalaryDetail[] $teacher_salary_details
 *
 * @package App\Models
 */
class TeacherSalarySheet extends Model
{
	protected $table = 'teacher_salary_sheet';

	protected $casts = [
		'teacher_salary_sheet_id' => 'string',
		'school_id' => 'int',
		'teacher_id' => 'int',
		'semester_id' => 'int',
		'month' => 'int',
		'year' => 'int',
		'salary_grade_id' => 'int',
		'salary_config_id' => 'int',
		'coefficient_salary' => 'float',
		'seniority_allowance' => 'float',
		'position_allowance' => 'float',
		'total_periods_taught' => 'int',
		'teaching_pay' => 'float',
		'research_bonus' => 'float',
		'other_allowance' => 'float',
		'deductions' => 'float',
		'total_net_salary' => 'float',
		'confirmed_by' => 'int',
		'confirmed_at' => 'datetime',
		'paid_at' => 'datetime',
		'created_by' => 'int',
		'updated_by' => 'int'
	];

	protected $fillable = [
		'teacher_salary_sheet_id',
		'school_id',
		'teacher_id',
		'semester_id',
		'month',
		'year',
		'salary_grade_id',
		'salary_config_id',
		'coefficient_salary',
		'seniority_allowance',
		'position_allowance',
		'total_periods_taught',
		'teaching_pay',
		'research_bonus',
		'other_allowance',
		'deductions',
		'total_net_salary',
		'status',
		'confirmed_by',
		'confirmed_at',
		'paid_at',
		'notes',
		'created_by',
		'updated_by'
	];

	public function school()
	{
		return $this->belongsTo(School::class);
	}

	public function teacher()
	{
		return $this->belongsTo(Teacher::class);
	}

	public function semester()
	{
		return $this->belongsTo(Semester::class);
	}

	public function salary_grade()
	{
		return $this->belongsTo(SalaryGrade::class);
	}

	public function salary_config()
	{
		return $this->belongsTo(SalaryConfig::class);
	}

	public function user()
	{
		return $this->belongsTo(User::class, 'updated_by');
	}

	public function teacher_salary_details()
	{
		return $this->hasMany(TeacherSalaryDetail::class, 'salary_sheet_id');
	}
}
