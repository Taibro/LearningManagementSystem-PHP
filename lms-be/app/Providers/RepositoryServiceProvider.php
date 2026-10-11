<?php

namespace App\Providers;

use App\Repositories\Contracts\CourseRepositoryInterface;
use App\Repositories\Eloquent\EloquentCourseRepository;
use Illuminate\Support\ServiceProvider;

class RepositoryServiceProvider extends ServiceProvider
{
    public array $bindings = [
        CourseRepositoryInterface::class => EloquentCourseRepository::class,
    ];

    /**
     * Register services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap services.
     */
    public function boot(): void
    {
        //
    }
}
