<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Class UsersTableSeeder
 * @package Database\Seeders
 */
class UsersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('users')->insert([
            [
                'name' => 'nagi125',
                'email' => 'nagi125.dev@gmail.com',
                'email_verified_at' => Carbon::now(),
                'password' => bcrypt('test1234'),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);

        User::factory(3)->create();
    }
}
