<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class School extends Model
{
    protected $table = 'schools';

    protected $fillable = [
        'school_id',
        'code',
        'name',
        'domain',
        'address',
        'phone',
        'email',
        'logo_url',
        'subscription_status',
        'is_active',
        'created_by',
        'updated_by',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
        ];
    }

    public function users(): HasMany
    {
        return $this->hasMany(User::class, 'school_id');
    }

    public function students(): HasMany
    {
        return $this->hasMany(Student::class, 'school_id');
    }

    public function teachers(): HasMany
    {
        return $this->hasMany(Teacher::class, 'school_id');
    }
}

