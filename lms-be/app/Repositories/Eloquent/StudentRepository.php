<?php

namespace App\Repositories\Eloquent;

use App\Models\Student;
use App\Repositories\Contracts\StudentRepositoryInterface;
use Illuminate\Database\Eloquent\Builder;

/**
 * @extends BaseRepository<Student>
 */
class StudentRepository extends BaseRepository implements StudentRepositoryInterface
{
    protected ?string $connection = 'pgsql_owner';

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

    /**
     * Build a query on the default tenant RLS connection instead of pgsql_owner.
     *
     * @return Builder<Student>
     */
    protected function tenantQuery(): Builder
    {
        /** @var Builder<Student> $builder */
        $builder = $this->model->newQuery();

        return $builder;
    }

    public function findProfileByUserId(int $userId, int $schoolId): ?Student
    {
        return $this->tenantQuery()
            ->with(['user', 'department', 'school'])
            ->where('user_id', $userId)
            ->where('school_id', $schoolId)
            ->first();
    }

    public function updateProfile(Student $student, array $data): Student
    {
        $student->setConnection(null);
        $student->update($data);

        return $student->fresh(['user', 'department', 'school']) ?? $student;
    }
}
