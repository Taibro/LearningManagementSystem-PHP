<?php

namespace App\Models;

use App\Concerns\BelongsToSchool;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Student extends Model
{
    use BelongsToSchool;

    protected $table = 'students';

    protected $fillable = [
        'students_id',
        'school_id',
        'user_id',
        'department_id',
        'student_code',
        'date_of_birth',
        'gender',
        'address',
        'enrollment_date',
        'PlaceOfBirth',
        'Population',
        'Major',
        'DegreeLevel',
        'TrainingType',
        'AdministrativeClass',
        'enrollment_status',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'date_of_birth' => 'date',
            'enrollment_date' => 'date',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class, 'school_id');
    }
}

