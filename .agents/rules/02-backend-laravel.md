# Laravel 13 Backend Standards, Model Rules & Endpoint Workflow

## 1. PHP Reserved Keyword Constraint (`CourseClass`)
- **CRITICAL**: The database table is named `classes`.
- In PHP, `class` is a reserved language keyword.
- **NEVER** create or name an Eloquent model `App\Models\Class` because references like `Class::class` cause fatal PHP syntax errors (`syntax error, unexpected token "::", expecting ":"`).
- **ALWAYS** use `App\Models\CourseClass` (file `app/Models/CourseClass.php`) to represent the `classes` table.
- Configure generator config (`config/models.php`) with `'model_names' => ['classes' => 'CourseClass']`.

---

## 2. System Roles & Seed Accounts (Keycloak SSO + PostgreSQL)

### System Roles
All 7 canonical roles synchronized between Keycloak Realm Roles (`lms`) and the PostgreSQL `role` table:

```json
[
  { "name": "SAAS_ADMIN" },
  { "name": "SCHOOL_ADMIN" },
  { "name": "DEAN_OF_FACULTY" },
  { "name": "DEAN_OF_DEPARTMENT" },
  { "name": "LECTURER" },
  { "name": "STUDENT" },
  { "name": "GUEST" }
]
```

### Seed Users & Account Mapping
Baseline accounts are managed in Keycloak (`lms` realm) and linked into PostgreSQL (`users.keycloak_id` populated on register or lazy-synced from JWT `sub` claim on login). All baseline accounts use the default password `Password@123`:

| User Code | Full Name | Last Name | First Name | Username | Email | Role | School ID | School Code | Default Password |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `SA001` | Super Admin | Super | Admin | `sa001` | `superadmin@edusaas.io` | `SAAS_ADMIN` | `0` | `SAAS` | `Password@123` |
| `AD_HUIT_01` | Quản Trị HUIT | Quản | Trị HUIT | `ad_huit_01` | `admin@huit.edu.vn` | `SCHOOL_ADMIN` | `1` | `HUIT` | `Password@123` |
| `AD_HCMUT_01` | Quản Trị HCMUT | Quản | Trị HCMUT | `ad_hcmut_01` | `admin@hcmut.edu.vn` | `SCHOOL_ADMIN` | `2` | `HCMUT` | `Password@123` |
| `GV001` | Nguyễn Văn A | Nguyễn | Văn A | `gv001` | `nguyenvana@huit.edu.vn` | `LECTURER` | `1` | `HUIT` | `Password@123` |
| `2001230773` | Nguyễn Thành Tài | Nguyễn | Thành Tài | `2001230773` | `ntai8448@gmail.com` | `STUDENT` | `1` | `HUIT` | `Password@123` |
| `2001230774` | Vũ Quốc Việt | Vũ | Quốc Việt | `2001230774` | `viet123@gmail.com` | `STUDENT` | `1` | `HCMUT` | `Password@123` |

### Keycloak Realm Users JSON Spec (`lms-realm.json`)
```json
"users": [
  {
    "username": "sa001",
    "email": "superadmin@edusaas.io",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Admin",
    "lastName": "Super",
    "attributes": {
      "school_id": ["0"],
      "school_code": ["SAAS"],
      "user_code": ["SA001"]
    },
    "realmRoles": ["SAAS_ADMIN"],
    "credentials": [
      { "type": "password", "value": "Password@123", "temporary": false }
    ]
  },
  {
    "username": "ad_huit_01",
    "email": "admin@huit.edu.vn",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Trị HUIT",
    "lastName": "Quản",
    "attributes": {
      "school_id": ["1"],
      "school_code": ["HUIT"],
      "user_code": ["AD_HUIT_01"]
    },
    "realmRoles": ["SCHOOL_ADMIN"],
    "credentials": [
      { "type": "password", "value": "Password@123", "temporary": false }
    ]
  },
  {
    "username": "ad_hcmut_01",
    "email": "admin@hcmut.edu.vn",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Trị HCMUT",
    "lastName": "Quản",
    "attributes": {
      "school_id": ["2"],
      "school_code": ["HCMUT"],
      "user_code": ["AD_HCMUT_01"]
    },
    "realmRoles": ["SCHOOL_ADMIN"],
    "credentials": [
      { "type": "password", "value": "Password@123", "temporary": false }
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
      { "type": "password", "value": "Password@123", "temporary": false }
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
      { "type": "password", "value": "Password@123", "temporary": false }
    ]
  },
  {
    "username": "2001230774",
    "email": "viet123@gmail.com",
    "emailVerified": true,
    "enabled": true,
    "firstName": "Quốc Việt",
    "lastName": "Vũ",
    "attributes": {
      "school_id": ["1"],
      "school_code": ["HUIT"],
      "user_code": ["2001230774"]
    },
    "realmRoles": ["STUDENT"],
    "credentials": [
      { "type": "password", "value": "Password@123", "temporary": false }
    ]
  }
]
```

### Auth & Data Integrity Rules
- **No hardcoded data fallbacks**: NEVER auto-seed default schools (`HUIT`/`HCMUT`), fake `keycloak_id` UUIDs, or hardcoded username-to-role maps in Controllers or Services. If a tenant school or user record does not exist in PostgreSQL, fail explicitly with validation/domain errors.
- **Global code uniqueness**: Because all tenants share one Keycloak realm (`lms`) and `student_code` / `teacher_code` map to Keycloak `username`, both `students.student_code` and `teachers.teacher_code` MUST remain globally unique and case-insensitive (`UNIQUE` + `UPPER(...)` unique index).
- Passwords stored in `users.password_hash` must be hashed using `Illuminate\Support\Facades\Hash::make()`.
- Migration seeding must use `ON CONFLICT DO NOTHING` or `ON CONFLICT DO UPDATE` to ensure idempotent deployments.

---

## 3. Enterprise Endpoint Development Workflow (Controller -> DTO -> Service -> Repository)

Every new API feature in `lms-be` MUST follow this strict layered flow:

```text
HTTP Request
  -> Global Middleware (RequestLoggingMiddleware [X-Request-Id] + SecurityHeadersMiddleware)
  -> Route (/api/{version}/..., throttle:api / throttle:auth, auth:api, role:...)
  -> Controller (Thin: parse Request DTO -> call Service -> return JsonResponse)
  -> Request DTO (Validate & parse input + OpenAPI #[OA\Schema])
  -> Service (Business logic, Unit of Work transactions, Entity -> Response DTO mapping)
  -> RepositoryWrapper (Unit of Work - Scoped) -> Entity Repository (extends BaseRepository<TModel>)
  -> PostgreSQL (pgsql [RLS] or pgsql_owner [Auth/System bypass RLS])
```

### Step 1: Database Migration & Eloquent Model (`database/migrations/`, `app/Models/`)
- Define PostgreSQL columns in **lowercase** (`major`, `degreelevel`, `trainingtype`, `administrativeclass`, etc.) because PostgreSQL folds unquoted identifiers to lowercase while Eloquent quotes column names.
- In Eloquent Models:
  - Cast UUID columns to `'string'`, PostgreSQL `TIME` columns to `'string'`, and JSONB/array columns to `'array'`.
  - Keep PHPDoc compliant with Larastan/PHPStan:
    - Use `@property string` (NEVER `@property uuid`).
    - Use `@property CourseClass` and `@property Collection<int, CourseClass>` (NEVER `Class` or `Collection|Class[]`).
    - Use `@property string` / `string|null` for `TIME` columns (NEVER `time without time zone`).
    - Type nullable `BelongsTo`/`HasOne` properties as `Model|null` and declare explicit relation return types with generics (e.g., `/** @return BelongsTo<School, $this> */ public function school(): BelongsTo`).
  - In traits receiving `Illuminate\Database\Eloquent\Model` (such as `BelongsToSchool`), use `$model->getAttribute(...)` and `$model->setAttribute(...)` instead of magic property access.

### Step 2: Repository Layer (`app/Repositories/`)
- **NEVER** execute direct Eloquent queries (`Model::where(...)`, `Model::create(...)`) or raw `DB::` calls inside Controllers or Services.
- Every entity repository MUST extend `BaseRepository` and implement a contract extending `BaseRepositoryInterface`:
  1. **Contract** — `app/Repositories/Contracts/{Entity}RepositoryInterface.php`:
     - Declare `/** @extends BaseRepositoryInterface<ModelName> */`.
     - Add only domain-specific query signatures; inherit standard CRUD, condition queries (`findAll`, `findByCondition`, `findOneByCondition`, `findListByCondition`), batch operations (`batchCreate`, `batchUpdate`, `bulkDelete`), and pagination (`getPaged(): PagedResultDto`) from `BaseRepositoryInterface`.
  2. **Implementation** — `app/Repositories/Eloquent/{Entity}Repository.php`:
     - Declare `/** @extends BaseRepository<ModelName> */`.
     - Leave `protected ?string $connection = null;` (default `pgsql` with RLS) for standard tenant modules. Set `protected ?string $connection = 'pgsql_owner';` ONLY for Auth/system lookup repositories that run before RLS context is established.
     - Always build custom queries through `$this->query()` so connection routing stays consistent.
  3. **Unit of Work Registration**:
     - Bind `{Entity}RepositoryInterface::class => {Entity}Repository::class` in `app/Providers/RepositoryServiceProvider.php`.
     - Expose a lazy-loaded getter method on `RepositoryWrapperInterface` and `RepositoryWrapper` (registered via `$this->app->scoped(...)`).

### Step 3: Request & Response DTOs (`app/DTOs/{Module}/` & `app/DTOs/Common/`)
- **Request DTOs** (`final class {Action}RequestDto`):
  - Use `public readonly` constructor properties.
  - Provide `public static function fromRequest(Request $request): self` to run `$request->validate([...])` and construct the typed DTO.
- **Response DTOs** (`final class {Resource}ResponseDto implements JsonSerializable`):
  - Keep Response DTOs as **pure data structures** (do NOT put `fromModel()` or `fromArray()` Eloquent mapping logic inside DTOs).
  - Implement `toArray()` and `jsonSerialize()` with explicit PHPDoc `@return array<string, mixed>` (or `@return array<string, string>`).
  - Reuse shared common DTOs in `app/DTOs/Common/`:
    - `PagedResultDto` for paginated lists (`items`, `totalCount`, `pageNumber`, `pageSize`, `totalPages`).
    - `MessageResponseDto` for simple confirmation messages.
    - `ErrorResponseDto` for validation/error payloads (`message`, `errors`, `requestId`).
- **Swagger / OpenAPI Attributes on DTOs**:
  - Annotate DTO classes with `#[OA\Schema(schema: '...', title: '...', description: '...', required: [...])]`.
  - Annotate properties with plain `#[OA\Property]` (plus `nullable: true`, `description`, `type: 'array', items: ...` when needed).
  - **DO NOT** hardcode `example:` or synthetic formats (`email`, `uuid`, `uri`) on `#[OA\Property]`. Let `swagger-php` infer types from PHP type hints so Swagger UI renders native type placeholders (`"string"`, `0`, `true`, `["string"]`).

### Step 4: Service Layer (`app/Services/`)
- **Contracts**: Create an interface in `app/Services/Contracts/` when abstracting 3rd-party integrations or swappable providers (e.g. `AuthServiceInterface` -> `KeycloakAuthService`). Do not create unnecessary 1:1 interfaces for single-implementation internal domain services unless needed.
- **Dependencies**: Inject `RepositoryWrapperInterface $repositories` (Unit of Work) rather than injecting 5+ individual repository interfaces into the constructor.
- **Transactions**: Wrap multi-repository write operations in `$this->repositories->transaction(fn () => ..., $connection)`.
- **DTO Mapping Ownership**:
  - Service methods accept **Request DTOs** (and authenticated `User` / route IDs where needed).
  - Service methods perform all business rules, repository calls, and **directly construct & return Response DTOs** (`new ...ResponseDto(...)`, `array<int, ...ResponseDto>`, or `PagedResultDto`).

### Step 5: Controller Layer (`app/Http/Controllers/`)
- Extend `App\Http\Controllers\Controller` and build OpenAPI paths from `self::API_PREFIX` (`/api/{version}`).
- **Keep Controllers strictly thin**:
  - Inject ONLY the required Service(s) — NEVER inject `RepositoryWrapperInterface` or query Eloquent models directly.
  - NEVER map Response DTOs or embed business logic inside controller actions.
  - Each action simply:
    1. Parses & validates input into a Request DTO (`$dto = ...RequestDto::fromRequest($request);`).
    2. Calls the Service (`$result = $this->service->...($dto);`).
    3. Returns `response()->json($result, $statusCode)`.
  - Catch domain/validation exceptions only when mapping to custom HTTP status codes (e.g., `401` on login failure); let global API exception rendering in `bootstrap/app.php` standardize unhandled `401`, `403`, `404`, `422`, `429`, `500` responses with `ErrorResponseDto` + `requestId`.
- Document every endpoint with `#[OA\Get|Post|Put|Patch|Delete]` referencing Request & Response DTO classes via `new OA\JsonContent(ref: ...Dto::class)`.

### Step 6: Routing (`routes/api.php`)
- Register all API routes under the versioned group `Route::prefix('{version}')->where(['version' => 'v[0-9]+'])->middleware('throttle:api')`.
- Apply `auth:api` for JWT-protected endpoints, `role:...` (`RequireRole`) for RBAC authorization, and `throttle:auth` for brute-force-sensitive endpoints.

### Step 7: Verification Checklist (Mandatory before Commit/Push)
Run from `lms-be/`:
1. **Regenerate Swagger docs**:
   ```bash
   php artisan l5-swagger:generate
   ```
2. **Verify route registration**:
   ```bash
   php artisan route:list --path=api
   ```
3. **Run PHPStan / Larastan** (matches CI/CD in `.github/workflows/ci-backend.yml`):
   ```bash
   php vendor/bin/phpstan clear-result-cache
   php vendor/bin/phpstan analyse --memory-limit=512M --level=5 --no-progress
   ```
   *(Avoid unused traits/dead code and avoid unnecessary `?->` on the left side of `??` so PHPStan passes with 0 errors.)*
4. **Write & run Pest tests** (`tests/Feature/`):
   ```bash
   php vendor/bin/pest
   ```

---

## 4. RLS Context Enforcement in Controllers & Services
- Every tenant API call verified by `KeycloakJwtGuard` must invoke:
  ```php
  PostgresContextService::setContext(
      schoolId: (int) $user->school_id,
      userId: (int) $user->id,
      role: $primaryRole
  );
  ```
  before executing queries against the `pgsql` connection.
- Clear PostgreSQL session context before and after queued jobs (`Queue::before` / `Queue::after` in `AppServiceProvider`).
