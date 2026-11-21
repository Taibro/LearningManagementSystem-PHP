<?php

namespace App\Repositories\Contracts;

use App\Models\User;

/**
 * @extends BaseRepositoryInterface<User>
 */
interface UserRepositoryInterface extends BaseRepositoryInterface
{
    public function existsByEmailInSchool(string $email, int $schoolId): bool;

    public function findForJwtSync(
        string $keycloakId,
        string $email,
        int $schoolId,
        string $primaryRole
    ): ?User;

    public function findByEmailWithRoles(string $email): ?User;

    public function refreshWithProfiles(User $user): User;
}
