<?php

namespace App\Http\Middleware;

use Illuminate\Auth\Middleware\Authenticate as Middleware;

class Authenticate extends Middleware
{
    /**
     * Get the path the user should be redirected to when they are not authenticated.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return string|null
     */
    protected function redirectTo($request)
    {
        $redirectToRoute = 'login';
        $prefix = $request->segment(1);

        switch ($prefix) {
            case 'admin':
                $redirectToRoute = 'admin.login';
                break;
            default:
                $redirectToRoute = 'login';
                break;
        }

        if (! $request->expectsJson()) {
            return route($redirectToRoute);
        }
    }
}
