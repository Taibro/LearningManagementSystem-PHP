<?php

namespace App\Providers;

use App\Services\Auth\AuthCookieService;
use App\Services\Auth\KeycloakAuthService;
use App\Services\Auth\KeycloakJwksService;
use App\Services\Auth\KeycloakJwtGuard;
use App\Services\Contracts\AuthServiceInterface;
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
        if (class_exists(\Laravel\Fortify\Fortify::class)) {
            \Laravel\Fortify\Fortify::ignoreRoutes();
        }

        $this->app->bind(AuthServiceInterface::class, KeycloakAuthService::class);
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
            $guard = new KeycloakJwtGuard(
                $app->make(KeycloakJwksService::class),
                $app->make(AuthServiceInterface::class),
                $app->make(AuthCookieService::class),
                $app['request']
            );

            $app->refresh('request', $guard, 'setRequest');

            return $guard;
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
            return Limit::perMinute(100)->by((string) ($request->user()?->getAuthIdentifier() ?: $request->ip()));
        });

        RateLimiter::for('auth', function (Request $request) {
            return Limit::perMinute(20)->by((string) $request->ip());
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
