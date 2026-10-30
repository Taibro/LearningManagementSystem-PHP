<?php

use App\Http\Controllers\Api\V1\CourseController;
use App\Http\Controllers\Auth\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Authentication & Tenant Discovery Routes (Keycloak Direct Grant)
|--------------------------------------------------------------------------
*/
Route::get('/schools/active', [AuthController::class, 'activeSchools'])->name('schools.active');

Route::prefix('auth')->group(function () {
    Route::post('/login', [AuthController::class, 'login'])->name('auth.login');
    Route::post('/register', [AuthController::class, 'register'])->name('auth.register');
    Route::post('/refresh', [AuthController::class, 'refresh'])->name('auth.refresh');
    Route::post('/logout', [AuthController::class, 'logout'])->name('auth.logout');
    Route::post('/2fa/setup', [AuthController::class, 'setup2fa'])->name('auth.2fa.setup');
    Route::post('/2fa/verify-setup', [AuthController::class, 'verifySetup2fa'])->name('auth.2fa.verify-setup');
    Route::post('/login/verify-2fa', [AuthController::class, 'verifyLogin2fa'])->name('auth.login.verify-2fa');

    Route::middleware('auth:api')->group(function () {
        Route::get('/me', [AuthController::class, 'me'])->name('auth.me');
    });
});

/*
|--------------------------------------------------------------------------
| Protected API Routes (Keycloak JWT Guard + PostgreSQL RLS Context)
|--------------------------------------------------------------------------
*/
Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:api');

Route::prefix('{current_team}')
    ->middleware(['auth:api', 'verified', \App\Http\Middleware\EnsureTeamMembership::class])
    ->group(function () {
        Route::get('dashboard', \App\Http\Controllers\DashboardController::class)->name('dashboard');
    });

Route::middleware(['auth:api'])->group(function () {
    Route::post('invitations/{invitation}/accept', [\App\Http\Controllers\Teams\TeamInvitationController::class, 'accept'])->name('invitations.accept');
    Route::delete('invitations/{invitation}', [\App\Http\Controllers\Teams\TeamInvitationController::class, 'decline'])->name('invitations.decline');
});

require __DIR__.'/settings.php';

Route::prefix('v1')->middleware(['auth:api', 'throttle:api'])->group(function () {
    Route::apiResource('courses', CourseController::class);
});
