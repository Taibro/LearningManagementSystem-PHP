<?php

use App\DTOs\Auth\AuthTokenResponseDto;
use App\DTOs\Auth\LoginRequestDto;
use App\DTOs\Auth\LogoutRequestDto;
use App\DTOs\Auth\RefreshTokenRequestDto;
use App\DTOs\Auth\RefreshTokenResponseDto;
use App\DTOs\Auth\UserProfileResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\Models\Role;
use App\Models\School;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Repositories\Contracts\RoleRepositoryInterface;
use App\Repositories\Contracts\SchoolRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\Contracts\UserRoleRepositoryInterface;
use App\Services\Auth\AuthCookieService;
use App\Services\Auth\KeycloakAuthService;
use App\Services\Auth\KeycloakJwksService;
use App\Services\Contracts\AuthServiceInterface;
use Illuminate\Database\Connection;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Route;
use Illuminate\Validation\ValidationException;

function makeCookieStudentUser(int $id = 5, int $schoolId = 1): User
{
    $user = new User;
    $user->id = $id;
    $user->school_id = $schoolId;
    $user->full_name = 'Nguyễn Thành Tài';
    $user->email = 'ntai8448@gmail.com';
    $user->phone = '0901000005';
    $user->is_active = true;

    return $user;
}

function mockGuardPostgresContext(): void
{
    $pgsqlConnection = Mockery::mock(Connection::class);
    $pgsqlConnection->shouldReceive('select')
        ->atLeast()->once()
        ->withArgs(fn (string $sql): bool => str_contains($sql, 'set_config'))
        ->andReturn([]);

    DB::partialMock()
        ->shouldReceive('connection')
        ->with('pgsql')
        ->andReturn($pgsqlConnection);
    DB::shouldReceive('connection')->withNoArgs()->passthru();
    DB::shouldReceive('connection')->with(null)->passthru();
}

test('Unified login without userType infers real role from Keycloak JWT and keeps mismatch check when userType is provided', function () {
    $req = Request::create('/api/v1/auth/login', 'POST', [
        'loginCode' => 'gv001',
        'password' => 'Password@123',
        'school' => 'HUIT',
    ]);
    $dto = LoginRequestDto::fromRequest($req);
    expect($dto->userType)->toBeNull();

    Http::fake([
        '*protocol/openid-connect/token*' => Http::response([
            'access_token' => 'fake-lecturer-jwt',
            'refresh_token' => 'fake-lecturer-refresh',
            'expires_in' => 900,
        ], 200),
    ]);

    $payload = (object) [
        'sub' => 'kc-lecturer-uuid',
        'email' => 'nguyenvana@huit.edu.vn',
        'name' => 'Nguyễn Văn A',
        'school_code' => 'HUIT',
        'user_code' => 'GV001',
        'preferred_username' => 'gv001',
        'realm_access' => (object) ['roles' => ['LECTURER']],
    ];

    $jwks = Mockery::mock(KeycloakJwksService::class);
    $jwks->shouldReceive('decodeToken')->twice()->with('fake-lecturer-jwt')->andReturn($payload);

    $school = new School;
    $school->id = 1;
    $school->code = 'HUIT';
    $school->name = 'Trường ĐH Công Thương TP.HCM';
    $school->is_active = true;

    $teacher = new Teacher;
    $teacher->teacher_code = 'GV001';

    $user = new User;
    $user->id = 3;
    $user->school_id = 1;
    $user->email = 'nguyenvana@huit.edu.vn';
    $user->full_name = 'Nguyễn Văn A';
    $user->is_active = true;
    $user->setRelation('teacher', $teacher);
    $user->setRelation('student', null);

    $schoolRepo = Mockery::mock(SchoolRepositoryInterface::class);
    $schoolRepo->shouldReceive('findByCode')->with('HUIT')->andReturn($school);

    $teacherRepo = Mockery::mock(TeacherRepositoryInterface::class);
    $teacherRepo->shouldReceive('findByCodeInSchool')->with('gv001', 1)->andReturn(null);

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findByCodeInSchool')->with('gv001', 1)->andReturn(null);

    $userRepo = Mockery::mock(UserRepositoryInterface::class);
    $userRepo->shouldReceive('findForJwtSync')->once()->andReturn($user);
    $userRepo->shouldReceive('update')->once()->andReturn($user);
    $userRepo->shouldReceive('refreshWithProfiles')->once()->andReturn($user);

    $role = new Role;
    $role->id = 5;
    $role->name = 'LECTURER';

    $roleRepo = Mockery::mock(RoleRepositoryInterface::class);
    $roleRepo->shouldReceive('findByName')->with('LECTURER')->andReturn($role);

    $userRoleRepo = Mockery::mock(UserRoleRepositoryInterface::class);
    $userRoleRepo->shouldReceive('ensureUserRole')->once();

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('schools')->andReturn($schoolRepo);
    $repoWrapper->shouldReceive('teachers')->andReturn($teacherRepo);
    $repoWrapper->shouldReceive('students')->andReturn($studentRepo);
    $repoWrapper->shouldReceive('users')->andReturn($userRepo);
    $repoWrapper->shouldReceive('roles')->andReturn($roleRepo);
    $repoWrapper->shouldReceive('userRoles')->andReturn($userRoleRepo);
    $repoWrapper->shouldReceive('transaction')
        ->once()
        ->andReturnUsing(static fn (Closure $cb) => $cb());

    mockGuardPostgresContext();

    $service = new KeycloakAuthService($jwks, $repoWrapper);

    $result = $service->login($dto);
    expect($result->role)->toBe('LECTURER')
        ->and($result->teacherCode)->toBe('GV001')
        ->and($result->accessToken)->toBe('fake-lecturer-jwt');

    expect(fn () => $service->login(new LoginRequestDto(
        loginCode: 'gv001',
        password: 'Password@123',
        userType: 'STUDENT',
        school: 'HUIT',
    )))->toThrow(ValidationException::class);
});

test('POST /api/v1/auth/login attaches unencrypted HttpOnly cookies while keeping JSON tokens by default and hiding them with X-Auth-Mode: cookie', function () {
    $tokenDto = new AuthTokenResponseDto(
        token: 'jwt-access-123',
        accessToken: 'jwt-access-123',
        refreshToken: 'jwt-refresh-456',
        expiresIn: 900,
        id: 5,
        userId: 5,
        usersId: 'uuid-5',
        keycloakId: 'kc-5',
        userCode: '2001230773',
        studentCode: '2001230773',
        teacherCode: null,
        fullName: 'Nguyễn Thành Tài',
        email: 'ntai8448@gmail.com',
        phone: '0901000005',
        avatarUrl: null,
        role: 'STUDENT',
        roles: ['STUDENT'],
        schoolId: 1,
        schoolCode: 'HUIT',
        schoolName: 'Trường ĐH Công Thương TP.HCM',
    );

    $authService = Mockery::mock(AuthServiceInterface::class);
    $authService->shouldReceive('login')->twice()->andReturn($tokenDto);
    $this->app->instance(AuthServiceInterface::class, $authService);

    $resDefault = $this->postJson('/api/v1/auth/login', [
        'loginCode' => '2001230773',
        'password' => 'Password@123',
        'school' => 'HUIT',
    ]);

    $resDefault->assertOk()
        ->assertJsonPath('accessToken', 'jwt-access-123')
        ->assertJsonPath('role', 'STUDENT')
        ->assertPlainCookie('lms_access_token', 'jwt-access-123')
        ->assertPlainCookie('lms_refresh_token', 'jwt-refresh-456');

    $cookies = collect($resDefault->headers->getCookies())->keyBy->getName();
    expect($cookies->get('lms_access_token')?->isHttpOnly())->toBeTrue()
        ->and($cookies->get('lms_refresh_token')?->isHttpOnly())->toBeTrue();

    $resCookieOnly = $this->postJson('/api/v1/auth/login', [
        'loginCode' => '2001230773',
        'password' => 'Password@123',
        'school' => 'HUIT',
    ], ['X-Auth-Mode' => 'cookie']);

    $resCookieOnly->assertOk()
        ->assertJsonPath('token', null)
        ->assertJsonPath('accessToken', null)
        ->assertJsonPath('refreshToken', null)
        ->assertJsonPath('role', 'STUDENT')
        ->assertPlainCookie('lms_access_token', 'jwt-access-123')
        ->assertPlainCookie('lms_refresh_token', 'jwt-refresh-456');
});

test('AuthCookieService prioritizes Authorization Bearer header over Cookie', function () {
    $service = new AuthCookieService;

    $reqWithBoth = Request::create('/api/v1/auth/me', 'GET', [], ['lms_access_token' => 'cookie-jwt']);
    $reqWithBoth->headers->set('Authorization', 'Bearer bearer-jwt');

    expect($service->extractAccessTokenWithSource($reqWithBoth))->toBe([
        'token' => 'bearer-jwt',
        'source' => 'bearer',
    ]);

    $reqWithCookieOnly = Request::create('/api/v1/auth/me', 'GET', [], ['lms_access_token' => 'cookie-jwt']);
    expect($service->extractAccessTokenWithSource($reqWithCookieOnly))->toBe([
        'token' => 'cookie-jwt',
        'source' => 'cookie',
    ]);
});

test('GET /api/v1/auth/me authenticates via HttpOnly Cookie without Authorization header', function () {
    $user = makeCookieStudentUser();
    mockGuardPostgresContext();

    $payload = (object) ['sub' => 'kc-5', 'school_id' => 1];

    $jwks = Mockery::mock(KeycloakJwksService::class);
    $jwks->shouldReceive('decodeToken')->once()->with('cookie-jwt-token')->andReturn($payload);
    $this->app->instance(KeycloakJwksService::class, $jwks);

    $profileDto = new UserProfileResponseDto(
        id: 5,
        userId: 5,
        usersId: 'uuid-5',
        keycloakId: 'kc-5',
        fullName: 'Nguyễn Thành Tài',
        email: 'ntai8448@gmail.com',
        phone: '0901000005',
        avatarUrl: null,
        role: 'STUDENT',
        roles: ['STUDENT'],
        schoolId: 1,
        schoolCode: 'HUIT',
        schoolName: 'Trường ĐH Công Thương TP.HCM',
        studentCode: '2001230773',
        teacherCode: null,
    );

    $authService = Mockery::mock(AuthServiceInterface::class);
    $authService->shouldReceive('extractRolesFromPayload')->once()->with($payload)->andReturn(['STUDENT']);
    $authService->shouldReceive('resolvePrimaryRole')->once()->with(['STUDENT'])->andReturn('STUDENT');
    $authService->shouldReceive('syncUserWithDatabase')->once()->with($payload, 'STUDENT')->andReturn($user);
    $authService->shouldReceive('getCurrentUserProfile')->once()->with($user)->andReturn($profileDto);
    $this->app->instance(AuthServiceInterface::class, $authService);

    $this->withCredentials()
        ->withUnencryptedCookie('lms_access_token', 'cookie-jwt-token')
        ->getJson('/api/v1/auth/me')
        ->assertOk()
        ->assertJsonPath('studentCode', '2001230773')
        ->assertJsonPath('role', 'STUDENT');
});

test('Cookie-authenticated state-changing requests enforce Origin CSRF guard while allowing trusted Origin, Postman without Origin, and Bearer override', function () {
    Route::prefix('api/v1')
        ->middleware(['auth:api', 'role:STUDENT'])
        ->put('/_test/hybrid-cookie-write', fn () => response()->json(['ok' => true]));

    $user = makeCookieStudentUser();
    mockGuardPostgresContext();
    $payload = (object) ['sub' => 'kc-5', 'school_id' => 1];

    $jwks = Mockery::mock(KeycloakJwksService::class);
    $jwks->shouldReceive('decodeToken')->with('cookie-jwt-token')->andReturn($payload);
    $this->app->instance(KeycloakJwksService::class, $jwks);

    $authService = Mockery::mock(AuthServiceInterface::class);
    $authService->shouldReceive('extractRolesFromPayload')->andReturn(['STUDENT']);
    $authService->shouldReceive('resolvePrimaryRole')->andReturn('STUDENT');
    $authService->shouldReceive('syncUserWithDatabase')->andReturn($user);
    $this->app->instance(AuthServiceInterface::class, $authService);

    $this->withCredentials()
        ->withUnencryptedCookie('lms_access_token', 'cookie-jwt-token')
        ->putJson('/api/v1/_test/hybrid-cookie-write', ['sample' => 1], ['Origin' => 'https://evil.example.com'])
        ->assertStatus(403)
        ->assertJsonStructure(['message', 'requestId']);

    $this->withCredentials()
        ->withUnencryptedCookie('lms_access_token', 'cookie-jwt-token')
        ->putJson('/api/v1/_test/hybrid-cookie-write', ['sample' => 1], ['Origin' => 'http://localhost:5173'])
        ->assertOk()
        ->assertExactJson(['ok' => true]);

    $this->putJson('/api/v1/_test/hybrid-cookie-write', ['sample' => 1], [
        'Authorization' => 'Bearer cookie-jwt-token',
        'Origin' => 'https://evil.example.com',
    ])
        ->assertOk()
        ->assertExactJson(['ok' => true]);
});

test('POST /api/v1/auth/refresh and /logout work with empty JSON body by falling back to HttpOnly refresh cookie', function () {
    $authService = Mockery::mock(AuthServiceInterface::class);
    $authService->shouldReceive('refreshToken')
        ->once()
        ->withArgs(fn (RefreshTokenRequestDto $dto): bool => $dto->refreshToken === 'cookie-refresh-123')
        ->andReturn(new RefreshTokenResponseDto(
            token: 'new-access-999',
            accessToken: 'new-access-999',
            refreshToken: 'new-refresh-888',
            expiresIn: 900,
        ));
    $authService->shouldReceive('logout')
        ->once()
        ->withArgs(fn (LogoutRequestDto $dto): bool => $dto->refreshToken === 'cookie-refresh-123')
        ->andReturn(new MessageResponseDto('Đã đăng xuất thành công.'));
    $this->app->instance(AuthServiceInterface::class, $authService);

    $this->withCredentials()
        ->withUnencryptedCookie('lms_refresh_token', 'cookie-refresh-123')
        ->postJson('/api/v1/auth/refresh', [])
        ->assertOk()
        ->assertJsonPath('accessToken', 'new-access-999')
        ->assertPlainCookie('lms_access_token', 'new-access-999')
        ->assertPlainCookie('lms_refresh_token', 'new-refresh-888');

    $logoutRes = $this->withCredentials()
        ->withUnencryptedCookie('lms_refresh_token', 'cookie-refresh-123')
        ->postJson('/api/v1/auth/logout', []);

    $logoutRes->assertOk()
        ->assertJson(['message' => 'Đã đăng xuất thành công.'])
        ->assertCookieExpired('lms_access_token')
        ->assertCookieExpired('lms_refresh_token');
});

test('actingAs on api guard preserves authenticated user when a new request triggers setRequest()', function () {
    Route::prefix('api/v1')
        ->middleware(['auth:api', 'role:STUDENT'])
        ->get('/_test/acting-as-guard', fn () => response()->json(['ok' => true]));

    $user = makeCookieStudentUser();
    $user->setAttribute('jwt_role', 'STUDENT');
    $user->setAttribute('jwt_roles', ['STUDENT']);

    $this->actingAs($user, 'api')
        ->getJson('/api/v1/_test/acting-as-guard')
        ->assertOk()
        ->assertExactJson(['ok' => true]);
});

test('CORS middleware allows configured origins with credentials and blocks untrusted origins', function () {
    $schoolRepo = Mockery::mock(SchoolRepositoryInterface::class);
    $schoolRepo->shouldReceive('getActiveSchools')->andReturn(new \Illuminate\Database\Eloquent\Collection);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('schools')->andReturn($schoolRepo);
    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $preflightAllowed = $this->withHeaders([
        'Origin' => 'http://localhost:5173',
        'Access-Control-Request-Method' => 'POST',
    ])->options('/api/v1/auth/login');

    $preflightAllowed->assertStatus(204)
        ->assertHeader('Access-Control-Allow-Origin', 'http://localhost:5173')
        ->assertHeader('Access-Control-Allow-Credentials', 'true');

    $getAllowed = $this->withHeaders([
        'Origin' => 'http://127.0.0.1:5173',
    ])->getJson('/api/v1/schools/active');

    $getAllowed->assertOk()
        ->assertHeader('Access-Control-Allow-Origin', 'http://127.0.0.1:5173')
        ->assertHeader('Access-Control-Allow-Credentials', 'true');

    $pagesAllowed = $this->withHeaders([
        'Origin' => 'https://lms-fe-r8v.pages.dev',
    ])->getJson('/api/v1/schools/active');

    $pagesAllowed->assertOk()
        ->assertHeader('Access-Control-Allow-Origin', 'https://lms-fe-r8v.pages.dev')
        ->assertHeader('Access-Control-Allow-Credentials', 'true');

    $pagesPreviewAllowed = $this->withHeaders([
        'Origin' => 'https://7b9d3613.lms-fe-r8v.pages.dev',
    ])->getJson('/api/v1/schools/active');

    $pagesPreviewAllowed->assertOk()
        ->assertHeader('Access-Control-Allow-Origin', 'https://7b9d3613.lms-fe-r8v.pages.dev')
        ->assertHeader('Access-Control-Allow-Credentials', 'true');

    $pagesStrangerBlocked = $this->withHeaders([
        'Origin' => 'https://other-project.pages.dev',
    ])->getJson('/api/v1/schools/active');

    $pagesStrangerBlocked->assertOk();
    expect($pagesStrangerBlocked->headers->get('Access-Control-Allow-Origin'))->toBeNull();

    $getBlocked = $this->withHeaders([
        'Origin' => 'https://evil.example.com',
    ])->getJson('/api/v1/schools/active');

    $getBlocked->assertOk();
    expect($getBlocked->headers->get('Access-Control-Allow-Origin'))->toBeNull();
});
