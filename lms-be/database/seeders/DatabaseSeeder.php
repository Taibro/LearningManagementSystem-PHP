<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Baseline users and schools are seeded via database/sql/01_lms_schema.sql
        // and 2026_10_30_000003_seed_initial_schools_and_keycloak_users.php
    }
}
