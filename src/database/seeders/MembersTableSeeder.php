<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Member;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

/**
 * Class MembersTableSeeder
 * @package Database\Seeders
 */
class MembersTableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     *
     * @return void
     */
    public function run()
    {
        DB::table('members')->insert([
            [
                'name' => 'nagi125',
                'email' => 'nagi125.dev@gmail.com',
                'email_verified_at' => Carbon::now(),
                'password' => bcrypt('test1234'),
                'created_at' => Carbon::now(),
                'updated_at' => Carbon::now(),
            ],
        ]);

        Member::factory(10)->create();
    }
}
