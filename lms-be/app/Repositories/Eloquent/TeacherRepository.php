<?php

namespace App\Repositories\Eloquent;

use App\Models\Teacher;
use App\Repositories\Contracts\TeacherRepositoryInterface;

/**
 * @extends BaseRepository<Teacher>
 */
class TeacherRepository extends BaseRepository implements TeacherRepositoryInterface
{
    protected ?string $connection = 'pgsql_owner';

    public function __construct(Teacher $model)
    {
        parent::__construct($model);
    }

    public function existsByCode(string $teacherCode): bool
    {
        return $this->query()
            ->whereRaw('UPPER(teacher_code) = ?', [strtoupper(trim($teacherCode))])
            ->exists();
    }

    public function findByCodeInSchool(string $teacherCode, int $schoolId): ?Teacher
    {
        return $this->query()
            ->with('user')
            ->where('school_id', $schoolId)
            ->whereRaw('UPPER(teacher_code) = ?', [strtoupper(trim($teacherCode))])
            ->first();
    }

    public function firstOrCreateForUser(int $schoolId, int $userId, string $teacherCode): Teacher
    {
        return $this->query()->firstOrCreate(
            [
                'school_id' => $schoolId,
                'user_id' => $userId,
            ],
            [
                'teacher_code' => strtoupper(trim($teacherCode)),
                'hire_date' => now()->toDateString(),
                'status' => 'ACTIVE',
            ]
        );
    }
}
