<?php

namespace App\Repositories\Contracts;

use App\Models\Teacher;

/**
 * @extends BaseRepositoryInterface<Teacher>
 */
interface TeacherRepositoryInterface extends BaseRepositoryInterface
{
    public function existsByCode(string $teacherCode): bool;

    public function findByCodeInSchool(string $teacherCode, int $schoolId): ?Teacher;

    public function firstOrCreateForUser(int $schoolId, int $userId, string $teacherCode): Teacher;
}
