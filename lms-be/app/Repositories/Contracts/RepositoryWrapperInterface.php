<?php

namespace App\Repositories\Contracts;

use Closure;

interface RepositoryWrapperInterface
{
    public function schools(): SchoolRepositoryInterface;

    public function users(): UserRepositoryInterface;

    public function roles(): RoleRepositoryInterface;

    public function userRoles(): UserRoleRepositoryInterface;

    public function students(): StudentRepositoryInterface;

    public function teachers(): TeacherRepositoryInterface;

    public function imageUploads(): ImageUploadRepositoryInterface;

    /**
     * Execute a callback within a database transaction (Unit of Work).
     *
     * @template TReturn
     *
     * @param  Closure(): TReturn  $callback
     * @return TReturn
     */
    public function transaction(Closure $callback, ?string $connection = null): mixed;

    /**
     * Execute a callback using the privileged owner connection (bypasses RLS for pre-auth/system operations).
     *
     * @template TReturn
     *
     * @param  Closure(): TReturn  $callback
     * @return TReturn
     */
    public function asSystemOwner(Closure $callback): mixed;

    public function beginTransaction(?string $connection = null): void;

    public function commit(?string $connection = null): void;

    public function rollBack(?string $connection = null): void;
}
