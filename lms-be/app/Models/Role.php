<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    protected $table = 'role';

    protected $fillable = [
        'role_id',
        'name',
        'description',
        'is_system_role',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'is_system_role' => 'boolean',
        ];
    }
}

