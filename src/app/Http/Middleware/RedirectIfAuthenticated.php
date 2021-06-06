<?php

namespace App\Http\Middleware;

use App\Providers\RouteServiceProvider;
use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class RedirectIfAuthenticated
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @param  string|null  $guard
     * @return mixed
     */
    public function handle($request, Closure $next, $guard = null)
    {
        $redirectTo = '/';
        $prefix = $request->segment(1);

        switch ($prefix) {
            case 'admin':
                $guard = 'admin';
                $redirectTo = '/admin/dashboard';
                break;
            default:
                $guard = 'web';
                $redirectTo = '/';
                break;
        }

        if (Auth::guard($guard)->check()) {
            return redirect($redirectTo);
        }

        return $next($request);
    }
}
