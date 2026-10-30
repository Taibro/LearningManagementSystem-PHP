<?php

namespace App\Services\Database;

use Illuminate\Support\Facades\DB;

class PostgresContextService
{
    private static ?int $currentSchoolId = null;

    private static ?int $currentUserId = null;

    private static ?string $currentRole = null;

    public static function setContext(int $schoolId, int $userId, string $role): void
    {
        self::$currentSchoolId = $schoolId;
        self::$currentUserId = $userId;
        self::$currentRole = $role;

        DB::connection('pgsql')->select(
            "SELECT set_config('app.current_school_id', ?, false),
                    set_config('app.current_user_id', ?, false),
                    set_config('app.current_role', ?, false)",
            [(string) $schoolId, (string) $userId, $role]
        );
    }

    public static function clearContext(): void
    {
        self::$currentSchoolId = null;
        self::$currentUserId = null;
        self::$currentRole = null;

        DB::connection('pgsql')->statement(
            'RESET app.current_school_id; RESET app.current_user_id; RESET app.current_role;'
        );
    }

    public static function getSchoolId(): ?int
    {
        return self::$currentSchoolId;
    }

    public static function getUserId(): ?int
    {
        return self::$currentUserId;
    }

    public static function getRole(): ?string
    {
        return self::$currentRole;
    }
}

