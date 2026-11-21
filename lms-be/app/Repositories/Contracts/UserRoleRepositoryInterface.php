<?php

namespace App\Repositories\Contracts;

use App\Models\UserRole;

/**
 * @extends BaseRepositoryInterface<UserRole>
 */
interface UserRoleRepositoryInterface extends BaseRepositoryInterface
{
    public function assignRoleToUser(
        int $schoolId,
        int $userId,
        int $roleId,
        ?int $departmentId = null
    ): UserRole;

    public function ensureUserRole(int $schoolId, int $userId, int $roleId): UserRole;
}
