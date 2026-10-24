<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Schedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'course_class_id',
        'classroom_id',
        'day_of_week',
        'shift',
        'start_period',
        'end_period',
        'lesson_type',
    ];

    protected $casts = [
        'day_of_week' => 'integer',
        'shift' => 'integer',
        'start_period' => 'integer',
        'end_period' => 'integer',
    ];

    public function courseClass(): BelongsTo
    {
        return $this->belongsTo(CourseClass::class);
    }

    public function classroom(): BelongsTo
    {
        return $this->belongsTo(Classroom::class);
    }
}
