<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Semester extends Model
{
    use HasFactory;

    protected $fillable = [
        'semester_code',
        'name',
        'academic_year_start',
        'academic_year_end',
        'tuition_fee_per_credit',
        'start_date',
        'end_date',
        'tuition_deadline',
        'is_active',
    ];

    protected $casts = [
        'tuition_fee_per_credit' => 'decimal:2',
        'is_active' => 'boolean',
        'start_date' => 'date',
        'end_date' => 'date',
        'tuition_deadline' => 'date',
    ];

    public function courseClasses(): HasMany
    {
        return $this->hasMany(CourseClass::class);
    }

    public function tuitions(): HasMany
    {
        return $this->hasMany(Tuition::class);
    }
}
