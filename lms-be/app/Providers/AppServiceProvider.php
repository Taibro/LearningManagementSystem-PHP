<?php

namespace App\Providers;

use App\Services\Auth\KeycloakAuthService;
use App\Services\Auth\KeycloakJwksService;
use App\Services\Auth\KeycloakJwtGuard;
use App\Services\Database\PostgresContextService;
use Carbon\CarbonImmutable;
use Illuminate\Cache\RateLimiting\Limit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Date;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Queue;
use Illuminate\Support\Facades\RateLimiter;
use Illuminate\Support\ServiceProvider;
use Illuminate\Validation\Rules\Password;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        $this->configureDefaults();
        $this->configureRateLimiting();

        // When running in CLI (migrate, seed), automatically switch to owner connection for DDL privileges and RLS bypass
        if ($this->app->runningInConsole()) {
            $default = config('database.default');
            if (in_array($default, ['pgsql', 'pgsql_owner'], true)) {
                config(['database.default' => 'pgsql_owner']);
            } elseif (in_array($default, ['pgsql_server', 'pgsql_server_owner'], true)) {
                config(['database.default' => 'pgsql_server_owner']);
            }
        }

        // Register stateless Keycloak JWT Guard for API requests
        Auth::extend('keycloak', function ($app, $name, array $config) {
            return new KeycloakJwtGuard(
                $app->make(KeycloakJwksService::class),
                $app->make(KeycloakAuthService::class),
                $app['request']
            );
        });

        Queue::before(fn () => PostgresContextService::clearContext());
        Queue::after(fn () => PostgresContextService::clearContext());
    }

    /**
     * Configure the rate limiters for the application.
     */
    protected function configureRateLimiting(): void
    {
        RateLimiter::for('api', function (Request $request) {
            return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
        });
    }

    /**
     * Configure default behaviors for production-ready applications.
     */
    protected function configureDefaults(): void
    {
        Date::use(CarbonImmutable::class);

        DB::prohibitDestructiveCommands(
            app()->isProduction(),
        );

        Password::defaults(fn (): ?Password => app()->isProduction()
            ? Password::min(12)
                ->mixedCase()
                ->letters()
                ->numbers()
                ->symbols()
                ->uncompromised()
            : null,
        );
    }
}
