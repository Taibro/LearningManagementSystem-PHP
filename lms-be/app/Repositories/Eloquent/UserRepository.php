<?php

namespace App\Repositories\Eloquent;

use App\Models\User;
use App\Repositories\Contracts\UserRepositoryInterface;

/**
 * @extends BaseRepository<User>
 */
class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(User $model)
    {
        parent::__construct($model);
    }

    public function existsByEmailInSchool(string $email, int $schoolId): bool
    {
        return $this->query()
            ->where('school_id', $schoolId)
            ->whereRaw('LOWER(email) = ?', [strtolower(trim($email))])
            ->exists();
    }

    public function findForJwtSync(
        string $keycloakId,
        string $email,
        int $schoolId,
        string $primaryRole
    ): ?User {
        return $this->query()
            ->with(['student', 'teacher', 'avatarUpload'])
            ->where(function ($q) use ($keycloakId, $email, $schoolId, $primaryRole) {
                if ($keycloakId !== '') {
                    $q->where('keycloak_id', $keycloakId);
                }

                if ($email !== '') {
                    if ($primaryRole === 'SAAS_ADMIN') {
                        $q->orWhereRaw('LOWER(email) = ?', [$email]);
                    } else {
                        $q->orWhere(function ($sub) use ($email, $schoolId) {
                            $sub->whereRaw('LOWER(email) = ?', [$email])
                                ->where('school_id', $schoolId);
                        });
                    }
                }
            })
            ->first();
    }

    public function findByEmailWithRoles(string $email): ?User
    {
        return $this->query()
            ->with('roles')
            ->whereRaw('LOWER(email) = ?', [strtolower(trim($email))])
            ->first();
    }

    public function refreshWithProfiles(User $user): User
    {
        $conn = $this->resolveConnectionName();
        if ($conn !== null) {
            $user->setConnection($conn);
        }

        return $user->fresh(['student', 'teacher', 'avatarUpload']) ?? $user;
    }

    public function existsByEmailInSchoolExceptUser(string $email, int $schoolId, int $excludeUserId): bool
    {
        return $this->query()
            ->where('school_id', $schoolId)
            ->where('id', '!=', $excludeUserId)
            ->whereRaw('LOWER(email) = ?', [strtolower(trim($email))])
            ->exists();
    }

    public function updateContact(User $user, array $data): User
    {
        $user->update($data);

        return $user->fresh(['avatarUpload']) ?? $user;
    }
}
