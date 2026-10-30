<?php

/**
 * Created by Reliese Model.
 */

namespace App\Models;

use App\Concerns\BelongsToSchool;
use Carbon\Carbon;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

/**
 * Class User
 *
 * @property int $id
 * @property string $users_id
 * @property int $school_id
 * @property string|null $keycloak_id
 * @property string $email
 * @property string|null $password_hash
 * @property string $full_name
 * @property string|null $phone
 * @property string|null $avatar_url
 * @property bool $is_active
 * @property bool $is_verified
 * @property Carbon|null $last_login_at
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property int|null $created_by
 * @property int|null $updated_by
 *
 * @property School $school
 * @property Student|null $student
 * @property Teacher|null $teacher
 * @property Collection|Role[] $roles
 */
class User extends Authenticatable
{
    use BelongsToSchool, HasFactory, Notifiable;

    protected $table = 'users';

    protected $casts = [
        'users_id' => 'string',
        'school_id' => 'int',
        'keycloak_id' => 'string',
        'is_active' => 'bool',
        'is_verified' => 'bool',
        'last_login_at' => 'datetime',
        'created_by' => 'int',
        'updated_by' => 'int',
    ];

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

    public function student(): HasOne
    {
        return $this->hasOne(Student::class, 'user_id');
    }

    public function teacher(): HasOne
    {
        return $this->hasOne(Teacher::class, 'user_id');
    }

    public function roles(): BelongsToMany
    {
        return $this->belongsToMany(Role::class, 'user_roles', 'user_id', 'role_id')
            ->withPivot(['id', 'user_roles_id', 'school_id', 'department_id', 'granted_by', 'granted_at', 'expires_at', 'is_active'])
            ->withTimestamps();
    }

    public function user()
    {
        return $this->belongsTo(User::class, 'updated_by');
    }

    public function schools()
    {
        return $this->hasMany(School::class, 'updated_by');
    }

    public function school_branches()
    {
        return $this->hasMany(SchoolBranch::class, 'updated_by');
    }

    public function academic_years()
    {
        return $this->hasMany(AcademicYear::class, 'updated_by');
    }

    public function semesters()
    {
        return $this->hasMany(Semester::class, 'updated_by');
    }

    public function departments()
    {
        return $this->hasMany(Department::class, 'updated_by');
    }

    public function users()
    {
        return $this->hasMany(User::class, 'updated_by');
    }

    public function teachers()
    {
        return $this->hasMany(Teacher::class, 'user_id');
    }

    public function students()
    {
        return $this->hasMany(Student::class, 'user_id');
    }

    public function courses()
    {
        return $this->hasMany(Course::class, 'updated_by');
    }

    public function rooms()
    {
        return $this->hasMany(Room::class, 'updated_by');
    }

    public function classes()
    {
        return $this->hasMany(CourseClass::class, 'updated_by');
    }

    public function schedules()
    {
        return $this->hasMany(Schedule::class, 'updated_by');
    }

    public function schedule_exceptions()
    {
        return $this->hasMany(ScheduleException::class, 'updated_by');
    }

    public function enrollments()
    {
        return $this->hasMany(Enrollment::class, 'updated_by');
    }

    public function attendance_records()
    {
        return $this->hasMany(AttendanceRecord::class, 'updated_by');
    }

    public function notifications()
    {
        return $this->hasMany(Notification::class, 'updated_by');
    }

    public function teacher_declarations()
    {
        return $this->hasMany(TeacherDeclaration::class, 'approved_by');
    }

    public function class_materials()
    {
        return $this->hasMany(ClassMaterial::class, 'uploaded_by');
    }

    public function class_teachers()
    {
        return $this->hasMany(ClassTeacher::class, 'updated_by');
    }

    public function teacher_salary_sheets()
    {
        return $this->hasMany(TeacherSalarySheet::class, 'updated_by');
    }

    public function audit_logs()
    {
        return $this->hasMany(AuditLog::class);
    }

    public function system_error_logs()
    {
        return $this->hasMany(SystemErrorLog::class);
    }
}
