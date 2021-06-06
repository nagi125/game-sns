<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\Auth\LoginController;
use App\Http\Controllers\Admin\Auth\ForgotPasswordController;
use App\Http\Controllers\Admin\Auth\ResetPasswordController;
use App\Http\Controllers\Admin\DashboardController;

/** Auth */
Route::get('login', [LoginController::class, 'showLoginForm'])->name('admin.login');
Route::post('login', [LoginController::class, 'login']);
Route::post('logout', [LoginController::class, 'logout'])->name('admin.logout');

Route::prefix('password')->group(function() {
    Route::get('reset', [ForgotPasswordController::class, 'showLinkRequestForm'])->name('admin.password.request');
    Route::post('email', [ForgotPasswordController::class, 'sendResetLinkEmail'])->name('admin.password.email');
    Route::get('reset/{token}', [ResetPasswordController::class, 'showResetForm'])->name('admin.password.reset');
    Route::post('reset', [ResetPasswordController::class, 'reset'])->name('admin.password.update');
});

Route::middleware('auth:admin')->group(function() {
    Route::get('/', [DashboardController::class, 'index'])->name('admin.top');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('admin.dashboard.index');
});
