# Laravel 13 Backend Standards & Model Rules

## 1. PHP Reserved Keyword Constraint (`CourseClass`)
- **CRITICAL**: The database table is named `classes`.
- In PHP, `class` is a reserved language keyword.
- **NEVER** create or name an Eloquent model `App\Models\Class` because references like `Class::class` cause fatal PHP syntax errors (`syntax error, unexpected token "::", expecting ":"`).
- **ALWAYS** use `App\Models\CourseClass` (file `app/Models/CourseClass.php`) to represent the `classes` table.
- Configure generator config (`config/models.php`) with `'model_names' => ['classes' => 'CourseClass']`.

---

## 2. Seed Users & Account Mapping
Baseline seed accounts are configured in Keycloak (`lms-realm.json`) and dynamically synchronized into PostgreSQL upon login (Keycloak acts as the Single Source of Truth for passwords and user UUIDs):

| User Code | Full Name | Username | Email | Role | School ID | School Code | Default Password |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `SA001` | Super Admin | `sa001` | `superadmin@edusaas.io` | `SAAS_ADMIN` | `0` | `SAAS` | `SuperAdmin@2024` |
| `AD_HUIT_01` | Quản Trị HUIT | `ad_huit_01` | `admin@huit.edu.vn` | `SCHOOL_ADMIN` | `1` | `HUIT` | `Admin@123` |
| `AD_HCMUT_01` | Quản Trị HCMUT | `ad_hcmut_01` | `admin@hcmut.edu.vn` | `SCHOOL_ADMIN` | `2` | `HCMUT` | `Admin@123` |
| `GV001` | Nguyễn Văn A | `gv001` | `nguyenvana@huit.edu.vn` | `LECTURER` | `1` | `HUIT` | `Lecturer@123` |
| `2001230773` | Nguyễn Thành Tài | `2001230773` | `ntai8448@gmail.com` | `STUDENT` | `1` | `HUIT` | `Student@123` |

### Keycloak Realm Users JSON Spec (`lms-realm.json`)
```json
"users": [
  {
    "username": "sa001",
    "email": "superadmin@edusaas.io",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Super",
    "lastName": "Admin",
    "attributes": {
      "school_id": ["0"],
      "school_code": ["SAAS"],
      "user_code": ["SA001"]
    },
    "realmRoles": ["SAAS_ADMIN"],
    "credentials": [
      { "type": "password", "value": "SuperAdmin@2024", "temporary": false }
    ]
  },
  {
    "username": "ad_huit_01",
    "email": "admin@huit.edu.vn",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Quản Trị",
    "lastName": "HUIT",
    "attributes": {
      "school_id": ["1"],
      "school_code": ["HUIT"],
      "user_code": ["AD_HUIT_01"]
    },
    "realmRoles": ["SCHOOL_ADMIN"],
    "credentials": [
      { "type": "password", "value": "Admin@123", "temporary": false }
    ]
  },
  {
    "username": "ad_hcmut_01",
    "email": "admin@hcmut.edu.vn",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Quản Trị",
    "lastName": "HCMUT",
    "attributes": {
      "school_id": ["2"],
      "school_code": ["HCMUT"],
      "user_code": ["AD_HCMUT_01"]
    },
    "realmRoles": ["SCHOOL_ADMIN"],
    "credentials": [
      { "type": "password", "value": "Admin@123", "temporary": false }
    ]
  },
  {
    "username": "gv001",
    "email": "nguyenvana@huit.edu.vn",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Văn A",
    "lastName": "Nguyễn",
    "attributes": {
      "school_id": ["1"],
      "school_code": ["HUIT"],
      "user_code": ["GV001"]
    },
    "realmRoles": ["LECTURER"],
    "credentials": [
      { "type": "password", "value": "Lecturer@123", "temporary": false }
    ]
  },
  {
    "username": "2001230773",
    "email": "ntai8448@gmail.com",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Thành Tài",
    "lastName": "Nguyễn",
    "attributes": {
      "school_id": ["1"],
      "school_code": ["HUIT"],
      "user_code": ["2001230773"]
    },
    "realmRoles": ["STUDENT"],
    "credentials": [
      { "type": "password", "value": "Student@123", "temporary": false }
    ]
  }
]
```

- Passwords stored in `users.password_hash` must be hashed using `Illuminate\Support\Facades\Hash::make()`.
- Migration seeding must use `ON CONFLICT DO NOTHING` or `ON CONFLICT DO UPDATE` to ensure idempotent deployments.

---

## 3. Eloquent Model Type Casting
- Laravel Eloquent does not have a native `'uuid'` cast. For UUID primary or foreign keys, cast to `'string'` or omit.
- PostgreSQL `TIME` columns (`start_time`, `end_time`) should be cast to `'string'`.
- PostgreSQL JSONB / array columns should be cast to `'array'`.

---

## 4. RLS Context Enforcement in Controllers & Services
- Every tenant API call verified by `KeycloakJwtGuard` must invoke:
  ```php
  app(PostgresContextService::class)->setContext(
      schoolId: $user->school_id,
      userId: $user->id,
      role: $primaryRole
  );
  ```
  before executing queries against the `pgsql` connection.

