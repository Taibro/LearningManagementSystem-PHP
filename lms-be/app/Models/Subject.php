<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Subject extends Model
{
    use HasFactory;

    protected $fillable = [
        'subject_code',
        'name',
        'credits',
        'theory_periods',
        'practice_periods',
        'is_elective',
        'faculty_id',
    ];

    protected $casts = [
        'credits' => 'integer',
        'theory_periods' => 'integer',
        'practice_periods' => 'integer',
        'is_elective' => 'boolean',
    ];

    public function faculty(): BelongsTo
    {
        return $this->belongsTo(Faculty::class);
    }

    public function courseClasses(): HasMany
    {
        return $this->hasMany(CourseClass::class);
    }
}
