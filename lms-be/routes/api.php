<?php

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\HealthController;
use App\Http\Controllers\Student\StudentProfileController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Versioned API Routes (e.g. /api/{version}/health, /api/{version}/auth/login)
|--------------------------------------------------------------------------
*/
Route::prefix('{version}')->where(['version' => 'v[0-9]+'])->middleware('throttle:api')->group(function () {
    Route::get('/health', HealthController::class)->name('version.health');
    Route::get('/schools/active', [AuthController::class, 'activeSchools'])->name('version.schools.active');

    Route::middleware('throttle:auth')->group(function () {
        Route::post('/login', [AuthController::class, 'login'])->name('version.login');
        Route::post('/register', [AuthController::class, 'register'])->name('version.register');
    });

    Route::post('/logout', [AuthController::class, 'logout'])->name('version.logout');

    Route::prefix('auth')->group(function () {
        Route::middleware('throttle:auth')->group(function () {
            Route::post('/login', [AuthController::class, 'login'])->name('version.auth.login');
            Route::post('/register', [AuthController::class, 'register'])->name('version.auth.register');
        });

        Route::post('/refresh', [AuthController::class, 'refresh'])->name('version.auth.refresh');
        Route::post('/logout', [AuthController::class, 'logout'])->name('version.auth.logout');
        Route::post('/2fa/setup', [AuthController::class, 'setup2fa'])->name('version.auth.2fa.setup');
        Route::post('/2fa/verify-setup', [AuthController::class, 'verifySetup2fa'])->name('version.auth.2fa.verify-setup');
        Route::post('/login/verify-2fa', [AuthController::class, 'verifyLogin2fa'])->name('version.auth.login.verify-2fa');

        Route::middleware('auth:api')->group(function () {
            Route::get('/me', [AuthController::class, 'me'])->name('version.auth.me');
        });
    });

    Route::prefix('student')
        ->middleware(['auth:api', 'role:STUDENT'])
        ->group(function () {
            Route::get('/profile', [StudentProfileController::class, 'show'])->name('version.student.profile.show');
            Route::put('/profile', [StudentProfileController::class, 'update'])->name('version.student.profile.update');
        });

    Route::get('/user', function (Request $request) {
        return $request->user();
    })->middleware('auth:api')->name('version.user');
});
