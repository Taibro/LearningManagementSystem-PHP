<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

/**
 * Class CurriculumCourse
 *
 * @property int $id
 * @property string $curriculum_courses_id
 * @property int $school_id
 * @property int|null $department_id
 * @property string|null $major
 * @property int $semester_number
 * @property int $course_id
 * @property bool $is_mandatory
 * @property int $elective_group
 * @property int|null $elective_required_credits
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 *
 * @property School $school
 * @property Department|null $department
 * @property Course $course
 * @property User|null $user
 *
 * @package App\Models
 */
class CurriculumCourse extends Model
{
    protected $table = 'curriculum_courses';

    protected $casts = [
        'curriculum_courses_id' => 'string',
        'school_id' => 'int',
        'department_id' => 'int',
        'semester_number' => 'int',
        'course_id' => 'int',
        'is_mandatory' => 'bool',
        'elective_group' => 'int',
        'elective_required_credits' => 'int',
        'created_by' => 'int',
        'updated_by' => 'int',
    ];

    protected $fillable = [
        'curriculum_courses_id',
        'school_id',
        'department_id',
        'major',
        'semester_number',
        'course_id',
        'is_mandatory',
        'elective_group',
        'elective_required_credits',
        'created_by',
        'updated_by',
    ];

    /**
     * @return BelongsTo<School, $this>
     */
    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class);
    }

    /**
     * @return BelongsTo<Department, $this>
     */
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    /**
     * @return BelongsTo<Course, $this>
     */
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class, 'updated_by');
    }
}
