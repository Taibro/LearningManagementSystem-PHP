<?php

namespace App\Providers;

use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Repositories\Contracts\RoleRepositoryInterface;
use App\Repositories\Contracts\SchoolRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\Contracts\UserRoleRepositoryInterface;
use App\Repositories\Eloquent\RepositoryWrapper;
use App\Repositories\Eloquent\RoleRepository;
use App\Repositories\Eloquent\SchoolRepository;
use App\Repositories\Eloquent\StudentRepository;
use App\Repositories\Eloquent\TeacherRepository;
use App\Repositories\Eloquent\UserRepository;
use App\Repositories\Eloquent\UserRoleRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    /**
     * Individual repository interface bindings.
     *
     * @var array<class-string, class-string>
     */
    public array $bindings = [
        SchoolRepositoryInterface::class => SchoolRepository::class,
        UserRepositoryInterface::class => UserRepository::class,
        RoleRepositoryInterface::class => RoleRepository::class,
        UserRoleRepositoryInterface::class => UserRoleRepository::class,
        StudentRepositoryInterface::class => StudentRepository::class,
        TeacherRepositoryInterface::class => TeacherRepository::class,
    ];

    /**
     * Register repository wrapper (Unit of Work) as scoped per request / job.
     */
    public function register(): void
    {
        $this->app->scoped(RepositoryWrapperInterface::class, RepositoryWrapper::class);
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
