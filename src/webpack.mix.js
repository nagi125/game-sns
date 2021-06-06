const mix = require('laravel-mix');

/*
 |--------------------------------------------------------------------------
 | Mix Asset Management
 |--------------------------------------------------------------------------
 |
 | Mix provides a clean, fluent API for defining some Webpack build steps
 | for your Laravel applications. By default, we are compiling the CSS
 | file for the application as well as bundling up all the JS files.
 |
 */

mix.sass('resources/sass/app.sass', 'public/css/app.css')
    .sass('resources/sass/admin/app.sass', 'public/css/app_admin.css')
    .js('resources/js/app.js', 'public/js/app.js')
    .js('resources/js/admin/app.js', 'public/js/app_admin.js');
