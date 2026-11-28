<?php

namespace App\Repositories\Eloquent;

use App\Models\UserRole;
use App\Repositories\Contracts\UserRoleRepositoryInterface;

/**
 * @extends BaseRepository<UserRole>
 */
class UserRoleRepository extends BaseRepository implements UserRoleRepositoryInterface
{
    public function __construct(UserRole $model)
    {
        parent::__construct($model);
    }

    public function assignRoleToUser(
        int $schoolId,
        int $userId,
        int $roleId,
        ?int $departmentId = null
    ): UserRole {
        return $this->query()->updateOrCreate(
            [
                'school_id' => $schoolId,
                'user_id' => $userId,
                'role_id' => $roleId,
            ],
            [
                'department_id' => $departmentId,
                'is_active' => true,
            ]
        );
    }

    public function ensureUserRole(int $schoolId, int $userId, int $roleId): UserRole
    {
        return $this->query()->firstOrCreate(
            [
                'school_id' => $schoolId,
                'user_id' => $userId,
                'role_id' => $roleId,
            ],
            [
                'is_active' => true,
            ]
        );
    }
}
