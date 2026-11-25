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

    public function existsByEmailInSchoolExceptUser(string $email, int $schoolId, int $excludeUserId): bool;

    /**
     * @param  array<string, mixed>  $data
     */
    public function updateContact(User $user, array $data): User;
}
