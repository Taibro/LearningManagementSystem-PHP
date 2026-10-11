<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

Route::prefix('{current_team}')
    ->middleware(['auth:sanctum', 'verified', \App\Http\Middleware\EnsureTeamMembership::class])
    ->group(function () {
        Route::get('dashboard', \App\Http\Controllers\DashboardController::class)->name('dashboard');
    });

Route::middleware(['auth:sanctum'])->group(function () {
    Route::post('invitations/{invitation}/accept', [\App\Http\Controllers\Teams\TeamInvitationController::class, 'accept'])->name('invitations.accept');
    Route::delete('invitations/{invitation}', [\App\Http\Controllers\Teams\TeamInvitationController::class, 'decline'])->name('invitations.decline');
});

require __DIR__.'/settings.php';

use App\Http\Controllers\Api\V1\CourseController;

Route::prefix('v1')->middleware(['auth:sanctum', 'throttle:api'])->group(function () {
    Route::apiResource('courses', CourseController::class);
});
