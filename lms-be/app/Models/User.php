<?php

namespace App\Models;

use App\Concerns\BelongsToSchool;
use Database\Factories\UserFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use BelongsToSchool, HasApiTokens, HasFactory, Notifiable;

    protected $table = 'users';

    protected $fillable = [
        'users_id',
        'school_id',
        'keycloak_id',
        'email',
        'password_hash',
        'full_name',
        'phone',
        'avatar_url',
        'is_active',
        'is_verified',
        'last_login_at',
        'created_by',
        'updated_by',
    ];

    protected $hidden = [
        'password_hash',
    ];

    protected function casts(): array
    {
        return [
            'is_active' => 'boolean',
            'is_verified' => 'boolean',
            'last_login_at' => 'datetime',
        ];
    }

    public function getNameAttribute(): string
    {
        return (string) ($this->attributes['full_name'] ?? '');
    }

    public function setNameAttribute(?string $value): void
    {
        $this->attributes['full_name'] = $value;
    }

    public function getAuthPassword(): string
    {
        return (string) ($this->attributes['password_hash'] ?? '');
    }

    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class, 'school_id');
    }

    public function userRoles(): HasMany
    {
        return $this->hasMany(UserRole::class, 'user_id');
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'user_roles', 'user_id', 'role_id')
            ->withPivot(['school_id', 'department_id', 'is_active', 'granted_at', 'expires_at'])
            ->wherePivot('is_active', true);
    }

    public function student(): HasOne
    {
        return $this->hasOne(Student::class, 'user_id');
    }

    public function teacher(): HasOne
    {
        return $this->hasOne(Teacher::class, 'user_id');
    }
}
