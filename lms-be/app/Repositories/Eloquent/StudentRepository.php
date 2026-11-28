<?php

namespace App\Repositories\Eloquent;

use App\Models\Student;
use App\Repositories\Contracts\StudentRepositoryInterface;

/**
 * @extends BaseRepository<Student>
 */
class StudentRepository extends BaseRepository implements StudentRepositoryInterface
{
    public function __construct(Student $model)
    {
        parent::__construct($model);
    }

    public function existsByCode(string $studentCode): bool
    {
        return $this->query()
            ->whereRaw('UPPER(student_code) = ?', [strtoupper(trim($studentCode))])
            ->exists();
    }

    public function findByCodeInSchool(string $studentCode, int $schoolId): ?Student
    {
        return $this->query()
            ->with('user')
            ->where('school_id', $schoolId)
            ->whereRaw('UPPER(student_code) = ?', [strtoupper(trim($studentCode))])
            ->first();
    }

    public function firstOrCreateForUser(int $schoolId, int $userId, string $studentCode): Student
    {
        return $this->query()->firstOrCreate(
            [
                'school_id' => $schoolId,
                'user_id' => $userId,
            ],
            [
                'student_code' => strtoupper(trim($studentCode)),
                'enrollment_date' => now()->toDateString(),
                'enrollment_status' => 'ENROLLED',
            ]
        );
    }

    public function findProfileByUserId(int $userId, int $schoolId): ?Student
    {
        return $this->query()
            ->with(['user.avatarUpload', 'department', 'school'])
            ->where('user_id', $userId)
            ->where('school_id', $schoolId)
            ->first();
    }

    public function updateProfile(Student $student, array $data): Student
    {
        $student->update($data);

        return $student->fresh(['user.avatarUpload', 'department', 'school']) ?? $student;
    }
}
