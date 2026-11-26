<?php

namespace App\Repositories\Contracts;

use App\Models\Student;

/**
 * @extends BaseRepositoryInterface<Student>
 */
interface StudentRepositoryInterface extends BaseRepositoryInterface
{
    public function existsByCode(string $studentCode): bool;

    public function findByCodeInSchool(string $studentCode, int $schoolId): ?Student;

    public function firstOrCreateForUser(int $schoolId, int $userId, string $studentCode): Student;

    public function findProfileByUserId(int $userId, int $schoolId): ?Student;

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateProfile(Student $student, array $data): Student;
}
