<?php

namespace App\Repositories\Eloquent;

use App\Repositories\Contracts\ImageUploadRepositoryInterface;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Repositories\Contracts\RoleRepositoryInterface;
use App\Repositories\Contracts\SchoolRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\Contracts\UserRoleRepositoryInterface;
use Closure;
use Illuminate\Contracts\Container\Container;
use Illuminate\Support\Facades\DB;

class RepositoryWrapper implements RepositoryWrapperInterface
{
    private ?SchoolRepositoryInterface $schoolRepository = null;

    private ?UserRepositoryInterface $userRepository = null;

    private ?RoleRepositoryInterface $roleRepository = null;

    private ?UserRoleRepositoryInterface $userRoleRepository = null;

    private ?StudentRepositoryInterface $studentRepository = null;

    private ?TeacherRepositoryInterface $teacherRepository = null;

    private ?ImageUploadRepositoryInterface $imageUploadRepository = null;

    public function __construct(
        private readonly Container $container,
    ) {}

    public function schools(): SchoolRepositoryInterface
    {
        return $this->schoolRepository ??= $this->container->make(SchoolRepositoryInterface::class);
    }

    public function users(): UserRepositoryInterface
    {
        return $this->userRepository ??= $this->container->make(UserRepositoryInterface::class);
    }

    public function roles(): RoleRepositoryInterface
    {
        return $this->roleRepository ??= $this->container->make(RoleRepositoryInterface::class);
    }

    public function userRoles(): UserRoleRepositoryInterface
    {
        return $this->userRoleRepository ??= $this->container->make(UserRoleRepositoryInterface::class);
    }

    public function students(): StudentRepositoryInterface
    {
        return $this->studentRepository ??= $this->container->make(StudentRepositoryInterface::class);
    }

    public function teachers(): TeacherRepositoryInterface
    {
        return $this->teacherRepository ??= $this->container->make(TeacherRepositoryInterface::class);
    }

    public function imageUploads(): ImageUploadRepositoryInterface
    {
        return $this->imageUploadRepository ??= $this->container->make(ImageUploadRepositoryInterface::class);
    }

    public function transaction(Closure $callback, ?string $connection = null): mixed
    {
        return DB::connection($connection)->transaction($callback);
    }

    public function asSystemOwner(Closure $callback): mixed
    {
        $ownerConnection = $this->resolveOwnerConnectionName();

        return BaseRepository::withConnection($ownerConnection, $callback);
    }

    public function beginTransaction(?string $connection = null): void
    {
        DB::connection($connection)->beginTransaction();
    }

    public function commit(?string $connection = null): void
    {
        DB::connection($connection)->commit();
    }

    public function rollBack(?string $connection = null): void
    {
        DB::connection($connection)->rollBack();
    }

    private function resolveOwnerConnectionName(): ?string
    {
        $default = (string) config('database.default');

        return match ($default) {
            'pgsql', 'pgsql_owner' => 'pgsql_owner',
            'pgsql_server', 'pgsql_server_owner' => 'pgsql_server_owner',
            default => null,
        };
    }
}
