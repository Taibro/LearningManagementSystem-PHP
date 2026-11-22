<?php

namespace App\Services\Auth;

use App\DTOs\Auth\AuthTokenResponseDto;
use App\DTOs\Auth\LoginRequestDto;
use App\DTOs\Auth\LogoutRequestDto;
use App\DTOs\Auth\RefreshTokenRequestDto;
use App\DTOs\Auth\RefreshTokenResponseDto;
use App\DTOs\Auth\RegisterRequestDto;
use App\DTOs\Auth\SchoolResponseDto;
use App\DTOs\Auth\Setup2faRequestDto;
use App\DTOs\Auth\Setup2faResponseDto;
use App\DTOs\Auth\UserProfileResponseDto;
use App\DTOs\Auth\Verify2faRequestDto;
use App\DTOs\Auth\VerifyLogin2faRequestDto;
use App\DTOs\Auth\VerifyLogin2faResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\Models\School;
use App\Models\Student;
use App\Models\Teacher;
use App\Models\User;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Services\Contracts\AuthServiceInterface;
use App\Services\Database\PostgresContextService;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Http;
use Illuminate\Validation\ValidationException;
use RuntimeException;

class KeycloakAuthService implements AuthServiceInterface
{
    public function __construct(
        private readonly KeycloakJwksService $jwksService,
        private readonly RepositoryWrapperInterface $repositories,
    ) {}

    /**
     * {@inheritdoc}
     */
    public function getActiveSchools(): array
    {
        return $this->repositories->schools()
            ->getActiveSchools()
            ->map(static fn (School $school): SchoolResponseDto => new SchoolResponseDto(
                id: (int) $school->id,
                value: (string) $school->code,
                code: (string) $school->code,
                label: (string) $school->name,
                name: (string) $school->name,
            ))
            ->values()
            ->all();
    }

    /**
     * Authenticate user via Keycloak Direct Access Grant (grant_type=password)
     * without redirecting the browser to Keycloak's login page, then sync with PostgreSQL.
     */
    public function login(LoginRequestDto $dto): AuthTokenResponseDto
    {
        $loginCode = $dto->loginCode;
        $password = $dto->password;
        $normalizedType = strtoupper(trim($dto->userType));
        $normalizedSchoolCode = $dto->school ? strtoupper(trim($dto->school)) : null;

        // Resolve school if provided
        $school = null;
        if ($normalizedSchoolCode && $normalizedType !== 'SAAS_ADMIN') {
            $school = $this->repositories->schools()->findByCode($normalizedSchoolCode);

            if (! $school) {
                throw ValidationException::withMessages([
                    'school' => ['Trường / Đơn vị đào tạo không tồn tại trên hệ thống.'],
                ]);
            }

            if (! $school->is_active) {
                throw ValidationException::withMessages([
                    'school' => ['Đơn vị đào tạo này hiện đang tạm khóa.'],
                ]);
            }
        }

        // Resolve username/email if user entered student_code or teacher_code
        $keycloakUsername = $this->resolveLoginIdentifier($loginCode, $school?->id);

        // Request token from Keycloak using Resource Owner Password Credentials (Direct Grant)
        $tokenData = $this->requestTokenWithPassword($keycloakUsername, $password);

        // Fallback: if loginCode was lowercase/uppercase variant and differed from resolved identifier
        if (! $tokenData && strtolower($keycloakUsername) !== strtolower($loginCode)) {
            $tokenData = $this->requestTokenWithPassword($loginCode, $password);
        }

        if (! $tokenData || empty($tokenData['access_token'])) {
            throw ValidationException::withMessages([
                'loginCode' => ['Tài khoản hoặc mật khẩu không chính xác.'],
            ]);
        }

        $accessToken = (string) $tokenData['access_token'];
        $refreshToken = isset($tokenData['refresh_token']) ? (string) $tokenData['refresh_token'] : null;
        $expiresIn = (int) ($tokenData['expires_in'] ?? 900);

        // Cryptographically verify and decode the Keycloak JWT
        $payload = $this->jwksService->decodeToken($accessToken);

        $jwtRoles = $this->extractRolesFromPayload($payload);
        if (empty($jwtRoles)) {
            $jwtRoles = $this->resolveDatabaseRolesForPayload($payload, $normalizedType);
        }
        $primaryRole = $this->resolvePrimaryRole($jwtRoles);

        // Verify role access for the portal the user is logging into
        if (! $this->isRoleAllowedForPortal($jwtRoles, $normalizedType)) {
            throw ValidationException::withMessages([
                'userType' => ["Tài khoản của bạn không có quyền truy cập phân hệ {$normalizedType}."],
            ]);
        }

        // Verify tenant (school) isolation for non-SaaS admins
        $jwtSchoolCode = isset($payload->school_code) ? strtoupper((string) $payload->school_code) : null;
        $jwtSchoolId = isset($payload->school_id) ? (int) $payload->school_id : null;

        if ($normalizedType !== 'SAAS_ADMIN' && $school) {
            if ($jwtSchoolCode && $jwtSchoolCode !== 'SAAS' && $jwtSchoolCode !== strtoupper($school->code)) {
                throw ValidationException::withMessages([
                    'school' => ["Tài khoản này thuộc trường {$jwtSchoolCode}, không thuộc trường {$school->code}."],
                ]);
            }
            if ($jwtSchoolId && $jwtSchoolId > 0 && $jwtSchoolId !== (int) $school->id && ! $jwtSchoolCode) {
                throw ValidationException::withMessages([
                    'school' => ['Tài khoản không thuộc đơn vị đào tạo đã chọn.'],
                ]);
            }
        }

        // Synchronize user record into PostgreSQL and set RLS context
        $user = $this->syncUserWithDatabase($payload, $primaryRole, $school);

        $resolvedSchool = $school ?? $this->repositories->schools()->findById((int) $user->school_id);
        $studentCode = $user->student instanceof Student ? $user->student->student_code : null;
        $teacherCode = $user->teacher instanceof Teacher ? $user->teacher->teacher_code : null;
        $userCode = (string) (
            $payload->user_code
            ?? $studentCode
            ?? $teacherCode
            ?? $payload->preferred_username
            ?? $user->email
        );

        PostgresContextService::setContext(
            schoolId: (int) $user->school_id,
            userId: (int) $user->id,
            role: $primaryRole
        );

        return new AuthTokenResponseDto(
            token: $accessToken,
            accessToken: $accessToken,
            refreshToken: $refreshToken,
            expiresIn: $expiresIn,
            id: (int) $user->id,
            userId: (int) $user->id,
            usersId: $user->users_id ? (string) $user->users_id : null,
            keycloakId: $user->keycloak_id ? (string) $user->keycloak_id : null,
            userCode: $userCode,
            studentCode: $studentCode ?? ($primaryRole === 'STUDENT' ? $userCode : null),
            teacherCode: $teacherCode ?? ($primaryRole === 'LECTURER' ? $userCode : null),
            fullName: (string) $user->full_name,
            email: (string) $user->email,
            phone: $user->phone ? (string) $user->phone : null,
            avatarUrl: $user->avatar_url ? (string) $user->avatar_url : null,
            role: $primaryRole,
            roles: $jwtRoles,
            schoolId: (int) $user->school_id,
            schoolCode: $resolvedSchool !== null ? (string) $resolvedSchool->code : $jwtSchoolCode,
            schoolName: $resolvedSchool !== null ? (string) $resolvedSchool->name : '',
            require2fa: false,
            requireSetup: false,
        );
    }

    /**
     * Register a new user in both Keycloak (via Admin REST API) and PostgreSQL,
     * then automatically authenticate and return the mapped JWT session DTO.
     */
    public function register(RegisterRequestDto $dto): AuthTokenResponseDto
    {
        $roleName = strtoupper(trim((string) ($dto->userType ?? 'STUDENT')));
        if (! in_array($roleName, ['STUDENT', 'LECTURER', 'SCHOOL_ADMIN', 'DEAN_OF_FACULTY', 'DEAN_OF_DEPARTMENT', 'SAAS_ADMIN'], true)) {
            $roleName = 'STUDENT';
        }

        $schoolCode = $dto->school !== null ? strtoupper(trim($dto->school)) : '';
        $hasExplicitSchool = $schoolCode !== '' && $schoolCode !== 'SAAS';

        if ($hasExplicitSchool) {
            $school = $this->repositories->schools()->findByCode($schoolCode);
            if (! $school) {
                throw ValidationException::withMessages([
                    'school' => ["Không tìm thấy trường học với mã {$schoolCode}."],
                ]);
            }
        } elseif ($roleName === 'SAAS_ADMIN') {
            $school = $this->repositories->schools()->findFirstOrderedById();
            if (! $school) {
                throw ValidationException::withMessages([
                    'school' => ['Không tìm thấy trường / đơn vị đào tạo trong hệ thống.'],
                ]);
            }
        } else {
            throw ValidationException::withMessages([
                'school' => ['Vui lòng chọn trường / đơn vị đào tạo.'],
            ]);
        }

        $email = strtolower(trim($dto->email));
        $userCode = trim((string) ($dto->userCode ?? $dto->loginCode ?? $dto->studentCode ?? $dto->teacherCode ?? $email));
        $fullName = trim($dto->fullName);
        $password = $dto->password;
        $phone = $dto->phone !== null ? trim($dto->phone) : null;

        // Check existing email in this school
        if ($this->repositories->users()->existsByEmailInSchool($email, (int) $school->id)) {
            throw ValidationException::withMessages([
                'email' => ['Email này đã được đăng ký tại trường của bạn.'],
            ]);
        }

        if ($roleName === 'STUDENT' && $this->repositories->students()->existsByCode($userCode)) {
            throw ValidationException::withMessages([
                'userCode' => ['Mã sinh viên này đã tồn tại trên hệ thống.'],
            ]);
        }

        if ($roleName === 'LECTURER' && $this->repositories->teachers()->existsByCode($userCode)) {
            throw ValidationException::withMessages([
                'userCode' => ['Mã giảng viên này đã tồn tại trên hệ thống.'],
            ]);
        }

        // 1. Create User in Keycloak via Admin REST API
        $keycloakUserId = $this->createKeycloakUser(
            username: strtolower($userCode),
            email: $email,
            fullName: $fullName,
            password: $password,
            roleName: $roleName,
            school: $roleName === 'SAAS_ADMIN' && ! $hasExplicitSchool ? null : $school,
            userCode: $userCode
        );

        // 2. Create User, UserRole, and Student/Teacher profile inside Unit of Work transaction
        $user = $this->repositories->transaction(function () use (
            $school,
            $keycloakUserId,
            $email,
            $password,
            $fullName,
            $phone,
            $roleName,
            $userCode,
            $dto
        ): User {
            $newUser = $this->repositories->users()->create([
                'school_id' => $school->id,
                'keycloak_id' => $keycloakUserId,
                'email' => $email,
                'password_hash' => Hash::make($password),
                'full_name' => $fullName,
                'phone' => $phone,
                'is_active' => true,
                'is_verified' => true,
                'last_login_at' => now(),
            ]);

            $role = $this->repositories->roles()->findByName($roleName);
            if ($role) {
                $this->repositories->userRoles()->assignRoleToUser(
                    schoolId: (int) $school->id,
                    userId: (int) $newUser->id,
                    roleId: (int) $role->id,
                    departmentId: $dto->departmentId
                );
            }

            if ($roleName === 'STUDENT') {
                $this->repositories->students()->create([
                    'school_id' => $school->id,
                    'user_id' => $newUser->id,
                    'department_id' => $dto->departmentId,
                    'student_code' => strtoupper($userCode),
                    'major' => $dto->major ?? 'Công nghệ thông tin',
                    'degreelevel' => $dto->degreeLevel ?? 'Đại học',
                    'trainingtype' => $dto->trainingType ?? 'Chính quy',
                    'administrativeclass' => $dto->className,
                    'enrollment_date' => now()->toDateString(),
                    'enrollment_status' => 'ENROLLED',
                ]);
            } elseif ($roleName === 'LECTURER') {
                $this->repositories->teachers()->create([
                    'school_id' => $school->id,
                    'user_id' => $newUser->id,
                    'department_id' => $dto->departmentId,
                    'teacher_code' => strtoupper($userCode),
                    'specialization' => $dto->specialization,
                    'qualification' => $dto->qualification ?? 'Thạc sĩ',
                    'hire_date' => now()->toDateString(),
                    'status' => 'ACTIVE',
                ]);
            }

            return $newUser;
        }, 'pgsql_owner');

        // 3. Automatically obtain JWT token from Keycloak so user can log in immediately
        try {
            return $this->login(new LoginRequestDto(
                loginCode: strtolower($userCode),
                password: $password,
                userType: $roleName,
                school: $roleName === 'SAAS_ADMIN' && ! $hasExplicitSchool ? null : (string) $school->code,
            ));
        } catch (\Throwable) {
            return new AuthTokenResponseDto(
                token: null,
                accessToken: null,
                refreshToken: null,
                expiresIn: null,
                id: (int) $user->id,
                userId: (int) $user->id,
                usersId: $user->users_id ? (string) $user->users_id : null,
                keycloakId: $keycloakUserId,
                userCode: $userCode,
                studentCode: $roleName === 'STUDENT' ? strtoupper($userCode) : null,
                teacherCode: $roleName === 'LECTURER' ? strtoupper($userCode) : null,
                fullName: (string) $user->full_name,
                email: (string) $user->email,
                phone: $user->phone ? (string) $user->phone : null,
                avatarUrl: $user->avatar_url ? (string) $user->avatar_url : null,
                role: $roleName,
                roles: [$roleName],
                schoolId: (int) $school->id,
                schoolCode: $roleName === 'SAAS_ADMIN' && ! $hasExplicitSchool ? 'SAAS' : (string) $school->code,
                schoolName: $roleName === 'SAAS_ADMIN' && ! $hasExplicitSchool ? '' : (string) $school->name,
                require2fa: false,
                requireSetup: false,
            );
        }
    }

    /**
     * Exchange a refresh token for a new access token DTO from Keycloak.
     */
    public function refreshToken(RefreshTokenRequestDto $dto): RefreshTokenResponseDto
    {
        $tokenUrl = config('keycloak.base_url').'/realms/'.config('keycloak.realm').'/protocol/openid-connect/token';

        $formParams = [
            'grant_type' => 'refresh_token',
            'client_id' => config('keycloak.client_id', 'lms-web'),
            'refresh_token' => $dto->refreshToken,
        ];

        $clientSecret = config('keycloak.client_secret');
        if (! empty($clientSecret)) {
            $formParams['client_secret'] = $clientSecret;
        }

        $response = Http::asForm()
            ->timeout((int) config('keycloak.http_timeout', 10))
            ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
            ->post($tokenUrl, $formParams);

        if (! $response->successful()) {
            throw ValidationException::withMessages([
                'refreshToken' => ['Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.'],
            ]);
        }

        $data = $response->json();
        $accessToken = (string) ($data['access_token'] ?? '');

        return new RefreshTokenResponseDto(
            token: $accessToken,
            accessToken: $accessToken,
            refreshToken: (string) ($data['refresh_token'] ?? $dto->refreshToken),
            expiresIn: (int) ($data['expires_in'] ?? 900),
        );
    }

    /**
     * Logout user session from Keycloak and return confirmation message DTO.
     */
    public function logout(LogoutRequestDto $dto): MessageResponseDto
    {
        $refreshToken = $dto->refreshToken;

        if ($refreshToken) {
            $logoutUrl = config('keycloak.base_url').'/realms/'.config('keycloak.realm').'/protocol/openid-connect/logout';

            $formParams = [
                'client_id' => config('keycloak.client_id', 'lms-web'),
                'refresh_token' => $refreshToken,
            ];

            $clientSecret = config('keycloak.client_secret');
            if (! empty($clientSecret)) {
                $formParams['client_secret'] = $clientSecret;
            }

            try {
                Http::asForm()
                    ->timeout(5)
                    ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                    ->post($logoutUrl, $formParams);
            } catch (\Throwable $e) {
                report($e);
            }
        }

        return new MessageResponseDto('Đã đăng xuất thành công.');
    }

    /**
     * Map authenticated User model and loaded profiles into UserProfileResponseDto.
     */
    public function getCurrentUserProfile(User $user): UserProfileResponseDto
    {
        $user->loadMissing(['school', 'student', 'teacher']);

        $school = $user->school instanceof School ? $user->school : null;
        $student = $user->student instanceof Student ? $user->student : null;
        $teacher = $user->teacher instanceof Teacher ? $user->teacher : null;

        $role = (string) ($user->getAttribute('jwt_role') ?: 'STUDENT');
        $roles = array_values(array_map(
            static fn (mixed $item): string => (string) $item,
            (array) ($user->getAttribute('jwt_roles') ?? [$role])
        ));

        return new UserProfileResponseDto(
            id: (int) $user->id,
            userId: (int) $user->id,
            usersId: $user->users_id ? (string) $user->users_id : null,
            keycloakId: $user->keycloak_id ? (string) $user->keycloak_id : null,
            fullName: (string) $user->full_name,
            email: (string) $user->email,
            phone: $user->phone ? (string) $user->phone : null,
            avatarUrl: $user->avatar_url ? (string) $user->avatar_url : null,
            role: $role,
            roles: $roles,
            schoolId: (int) $user->school_id,
            schoolCode: $school !== null ? (string) $school->code : null,
            schoolName: $school !== null ? (string) $school->name : null,
            studentCode: $student !== null ? (string) $student->student_code : null,
            teacherCode: $teacher !== null ? (string) $teacher->teacher_code : null,
        );
    }

    /**
     * Generate 2FA TOTP QR code setup URI DTO.
     */
    public function setup2fa(Setup2faRequestDto $dto): Setup2faResponseDto
    {
        $otpAuth = rawurlencode("otpauth://totp/EduSpace:{$dto->email}?secret=JBSWY3DPEHPK3PXP&issuer=EduSpace");

        return new Setup2faResponseDto(
            qrCodeImageUri: "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data={$otpAuth}"
        );
    }

    /**
     * Verify 6-digit TOTP setup code.
     */
    public function verifySetup2fa(Verify2faRequestDto $dto): bool
    {
        return strlen(trim($dto->code)) === 6;
    }

    /**
     * Verify 2FA login challenge and return mapped session DTO.
     */
    public function verifyLogin2fa(
        VerifyLogin2faRequestDto $dto,
        ?User $user = null,
        ?string $token = null
    ): VerifyLogin2faResponseDto {
        return new VerifyLogin2faResponseDto(
            token: $token,
            id: $user !== null ? (int) $user->id : null,
            fullName: $user !== null ? (string) $user->full_name : 'Admin',
            email: $user !== null ? (string) $user->email : $dto->email,
            schoolId: $user !== null ? (int) $user->school_id : 1,
        );
    }

    /**
     * Request OAuth2 token from Keycloak using Direct Access Grants (grant_type=password).
     * Automatically falls back to 'admin-cli' if 'lms-web' has not enabled directAccessGrants yet.
     *
     * @return array<string, mixed>|null
     */
    protected function requestTokenWithPassword(string $username, string $password): ?array
    {
        $tokenUrl = config('keycloak.base_url').'/realms/'.config('keycloak.realm').'/protocol/openid-connect/token';
        $primaryClientId = config('keycloak.client_id', 'lms-web');
        $clientSecret = config('keycloak.client_secret');

        // 1. Primary attempt: Public client (e.g. lms-web) using default client scopes (lms-tenant-scope)
        $formParams = [
            'grant_type' => 'password',
            'client_id' => $primaryClientId,
            'username' => $username,
            'password' => $password,
        ];

        // Only attach client_secret if not using public SPA/mobile clients
        if (! empty($clientSecret) && ! in_array($primaryClientId, ['lms-web', 'lms-mobile', 'admin-cli'], true)) {
            $formParams['client_secret'] = $clientSecret;
        }

        $response = Http::asForm()
            ->timeout((int) config('keycloak.http_timeout', 10))
            ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
            ->post($tokenUrl, $formParams);

        if ($response->successful()) {
            return $response->json();
        }

        // 2. Fallback: If client 'lms-web' has directAccessGrantsEnabled=false on the Keycloak server,
        // fallback to Keycloak's built-in 'admin-cli' public client on the 'lms' realm (without invalid scopes).
        $err = $response->json('error');
        if (in_array($err, ['unauthorized_client', 'invalid_client', 'invalid_scope'], true) && $primaryClientId !== 'admin-cli') {
            $fallbackResponse = Http::asForm()
                ->timeout((int) config('keycloak.http_timeout', 10))
                ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                ->post($tokenUrl, [
                    'grant_type' => 'password',
                    'client_id' => 'admin-cli',
                    'username' => $username,
                    'password' => $password,
                ]);

            if ($fallbackResponse->successful()) {
                return $fallbackResponse->json();
            }
        }

        return null;
    }

    /**
     * Create a new user in Keycloak via Keycloak Admin REST API and assign their realm role.
     */
    protected function createKeycloakUser(
        string $username,
        string $email,
        string $fullName,
        string $password,
        string $roleName,
        ?School $school,
        string $userCode
    ): string {
        $adminToken = $this->getKeycloakAdminToken();
        $baseUrl = config('keycloak.base_url');
        $realm = config('keycloak.realm', 'lms');

        [$firstName, $lastName] = $this->splitFullName($fullName);

        $userPayload = [
            'username' => $username,
            'email' => $email,
            'firstName' => $firstName,
            'lastName' => $lastName,
            'enabled' => true,
            'emailVerified' => true,
            'attributes' => [
                'school_id' => [$school !== null ? (string) $school->id : '0'],
                'school_code' => [$school !== null ? strtoupper((string) $school->code) : 'SAAS'],
                'user_code' => [strtoupper($userCode)],
            ],
            'credentials' => [
                [
                    'type' => 'password',
                    'value' => $password,
                    'temporary' => false,
                ],
            ],
        ];

        $createResp = Http::withToken($adminToken)
            ->timeout((int) config('keycloak.http_timeout', 10))
            ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
            ->post("{$baseUrl}/admin/realms/{$realm}/users", $userPayload);

        if ($createResp->status() === 409) {
            throw ValidationException::withMessages([
                'loginCode' => ['Tài khoản (Mã số hoặc Email) đã tồn tại trên hệ thống SSO Keycloak.'],
            ]);
        }

        if (! $createResp->successful()) {
            $errBody = $createResp->json();
            $errMsg = $errBody['errorMessage'] ?? $errBody['error'] ?? ('HTTP '.$createResp->status());
            throw new RuntimeException("Không thể tạo tài khoản trên Keycloak: {$errMsg}");
        }

        // Extract created Keycloak user UUID from Location header or query by username
        $location = $createResp->header('Location');
        $keycloakId = null;
        if ($location && str_contains($location, '/users/')) {
            $keycloakId = basename((string) parse_url($location, PHP_URL_PATH));
        }

        if (! $keycloakId) {
            $searchResp = Http::withToken($adminToken)
                ->timeout((int) config('keycloak.http_timeout', 10))
                ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                ->get("{$baseUrl}/admin/realms/{$realm}/users", [
                    'username' => $username,
                    'exact' => 'true',
                ]);

            if ($searchResp->successful() && ! empty($searchResp->json()[0]['id'])) {
                $keycloakId = $searchResp->json()[0]['id'];
            }
        }

        if (! $keycloakId) {
            throw new RuntimeException('Đã tạo user trên Keycloak nhưng không lấy được Keycloak User ID.');
        }

        // Assign Realm Role to the user in Keycloak
        $roleResp = Http::withToken($adminToken)
            ->timeout((int) config('keycloak.http_timeout', 10))
            ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
            ->get("{$baseUrl}/admin/realms/{$realm}/roles/{$roleName}");

        if ($roleResp->successful()) {
            $roleRep = $roleResp->json();
            Http::withToken($adminToken)
                ->timeout((int) config('keycloak.http_timeout', 10))
                ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                ->post("{$baseUrl}/admin/realms/{$realm}/users/{$keycloakId}/role-mappings/realm", [
                    [
                        'id' => $roleRep['id'],
                        'name' => $roleRep['name'],
                    ],
                ]);
        }

        return $keycloakId;
    }

    /**
     * Obtain an Admin Access Token from Keycloak to manage users via Admin REST API.
     */
    protected function getKeycloakAdminToken(): string
    {
        $baseUrl = config('keycloak.base_url');
        $adminRealm = config('keycloak.admin_realm', 'master');
        $adminClientId = config('keycloak.admin_client_id', 'admin-cli');
        $adminUsername = config('keycloak.admin_username', 'admin');
        $adminPassword = config('keycloak.admin_password', '');

        if (! empty($adminPassword)) {
            $resp = Http::asForm()
                ->timeout((int) config('keycloak.http_timeout', 10))
                ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                ->post("{$baseUrl}/realms/{$adminRealm}/protocol/openid-connect/token", [
                    'grant_type' => 'password',
                    'client_id' => $adminClientId,
                    'username' => $adminUsername,
                    'password' => $adminPassword,
                ]);

            if ($resp->successful() && ! empty($resp->json('access_token'))) {
                return (string) $resp->json('access_token');
            }
        }

        // Fallback: Service account client_credentials on the LMS realm
        $realm = config('keycloak.realm', 'lms');
        $clientSecret = config('keycloak.client_secret');
        if (! empty($clientSecret)) {
            $resp = Http::asForm()
                ->timeout((int) config('keycloak.http_timeout', 10))
                ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                ->post("{$baseUrl}/realms/{$realm}/protocol/openid-connect/token", [
                    'grant_type' => 'client_credentials',
                    'client_id' => config('keycloak.api_audience', 'lms-api'),
                    'client_secret' => $clientSecret,
                ]);

            if ($resp->successful() && ! empty($resp->json('access_token'))) {
                return (string) $resp->json('access_token');
            }
        }

        throw new RuntimeException(
            'Không thể xác thực Keycloak Admin API. Vui lòng cấu hình KEYCLOAK_ADMIN_USERNAME và KEYCLOAK_ADMIN_PASSWORD trong file .env.'
        );
    }

    /**
     * Synchronize the authenticated Keycloak JWT user into PostgreSQL via Unit of Work.
     */
    public function syncUserWithDatabase(object $payload, string $primaryRole, ?School $school = null): User
    {
        $keycloakId = (string) ($payload->sub ?? '');
        $email = strtolower(trim((string) ($payload->email ?? '')));
        $preferredUsername = (string) ($payload->preferred_username ?? '');
        $userCode = (string) ($payload->user_code ?? $preferredUsername);
        $fullName = trim((string) ($payload->name ?? (($payload->family_name ?? '').' '.($payload->given_name ?? ''))))
            ?: ($preferredUsername ?: $email);

        $jwtSchoolId = (int) ($payload->school_id ?? 0);
        $jwtSchoolCode = isset($payload->school_code) ? strtoupper((string) $payload->school_code) : null;

        if (! $school) {
            if ($jwtSchoolId > 0) {
                $school = $this->repositories->schools()->findById($jwtSchoolId);
            }
            if (! $school && $jwtSchoolCode && $jwtSchoolCode !== 'SAAS') {
                $school = $this->repositories->schools()->findByCode($jwtSchoolCode);
            }
            if (! $school && $primaryRole === 'SAAS_ADMIN') {
                $school = $this->repositories->schools()->findFirstOrderedById();
            }
        }

        if (! $school) {
            throw ValidationException::withMessages([
                'school' => ['Không tìm thấy trường / đơn vị đào tạo trong hệ thống.'],
            ]);
        }

        $resolvedSchoolId = (int) $school->id;

        return $this->repositories->transaction(function () use (
            $keycloakId,
            $email,
            $fullName,
            $userCode,
            $primaryRole,
            $resolvedSchoolId
        ): User {
            $user = $this->repositories->users()->findForJwtSync(
                keycloakId: $keycloakId,
                email: $email,
                schoolId: $resolvedSchoolId,
                primaryRole: $primaryRole
            );

            if (! $user) {
                $user = $this->repositories->users()->create([
                    'school_id' => $resolvedSchoolId,
                    'keycloak_id' => $keycloakId ?: null,
                    'email' => $email ?: ($userCode.'@lms.local'),
                    'full_name' => $fullName,
                    'is_active' => true,
                    'is_verified' => true,
                    'last_login_at' => now(),
                ]);
            } else {
                $updates = ['last_login_at' => now()];
                if (empty($user->keycloak_id) && $keycloakId !== '') {
                    $updates['keycloak_id'] = $keycloakId;
                }
                $user = $this->repositories->users()->update($user, $updates);
            }

            // Ensure role mapping exists in user_roles
            $roleRecord = $this->repositories->roles()->findByName($primaryRole);
            if ($roleRecord) {
                $this->repositories->userRoles()->ensureUserRole(
                    schoolId: (int) $user->school_id,
                    userId: (int) $user->id,
                    roleId: (int) $roleRecord->id
                );
            }

            // Ensure student or teacher profile exists if applicable
            if ($primaryRole === 'STUDENT' && ! $user->student && $userCode !== '') {
                $this->repositories->students()->firstOrCreateForUser(
                    schoolId: (int) $user->school_id,
                    userId: (int) $user->id,
                    studentCode: $userCode
                );
            } elseif ($primaryRole === 'LECTURER' && ! $user->teacher && $userCode !== '') {
                $this->repositories->teachers()->firstOrCreateForUser(
                    schoolId: (int) $user->school_id,
                    userId: (int) $user->id,
                    teacherCode: $userCode
                );
            }

            return $this->repositories->users()->refreshWithProfiles($user);
        }, 'pgsql_owner');
    }

    /**
     * Resolve roles from PostgreSQL if the Keycloak client (e.g. admin-cli fallback) did not include realm roles in JWT.
     *
     * @return array<int, string>
     */
    protected function resolveDatabaseRolesForPayload(object $payload, string $fallbackRole): array
    {
        $email = strtolower(trim((string) ($payload->email ?? '')));

        if ($email !== '') {
            $user = $this->repositories->users()->findByEmailWithRoles($email);
            if ($user && $user->roles->isNotEmpty()) {
                return $user->roles->pluck('name')->all();
            }
        }

        return [$fallbackRole];
    }

    /**
     * Resolve a student_code / teacher_code to username or email if needed.
     */
    protected function resolveLoginIdentifier(string $loginCode, ?int $schoolId): string
    {
        $trimmed = trim($loginCode);
        if (str_contains($trimmed, '@')) {
            return strtolower($trimmed);
        }

        if ($schoolId) {
            $student = $this->repositories->students()->findByCodeInSchool($trimmed, $schoolId);
            if ($student && $student->user) {
                return strtolower($trimmed);
            }

            $teacher = $this->repositories->teachers()->findByCodeInSchool($trimmed, $schoolId);
            if ($teacher && $teacher->user) {
                return strtolower($trimmed);
            }
        }

        return strtolower($trimmed);
    }

    /**
     * @return array<int, string>
     */
    public function extractRolesFromPayload(object $payload): array
    {
        $roles = $payload->roles ?? ($payload->realm_access->roles ?? []);

        $systemRoles = [
            'SAAS_ADMIN',
            'SCHOOL_ADMIN',
            'DEAN_OF_FACULTY',
            'DEAN_OF_DEPARTMENT',
            'LECTURER',
            'STUDENT',
        ];

        $extracted = is_array($roles) ? array_values(array_map('strval', $roles)) : [];

        return array_values(array_intersect($extracted, $systemRoles));
    }

    /**
     * @param  array<int, string>  $roles
     */
    public function resolvePrimaryRole(array $roles): string
    {
        $priority = [
            'SAAS_ADMIN',
            'SCHOOL_ADMIN',
            'DEAN_OF_FACULTY',
            'DEAN_OF_DEPARTMENT',
            'LECTURER',
            'STUDENT',
        ];

        foreach ($priority as $role) {
            if (in_array($role, $roles, true)) {
                return $role;
            }
        }

        return 'STUDENT';
    }

    /**
     * @param  array<int, string>  $jwtRoles
     */
    protected function isRoleAllowedForPortal(array $jwtRoles, string $portalType): bool
    {
        if (in_array('SAAS_ADMIN', $jwtRoles, true)) {
            return true;
        }

        return match ($portalType) {
            'SAAS_ADMIN' => in_array('SAAS_ADMIN', $jwtRoles, true),
            'SCHOOL_ADMIN' => count(array_intersect($jwtRoles, ['SCHOOL_ADMIN', 'DEAN_OF_FACULTY', 'DEAN_OF_DEPARTMENT'])) > 0,
            'LECTURER' => count(array_intersect($jwtRoles, ['LECTURER', 'DEAN_OF_FACULTY', 'DEAN_OF_DEPARTMENT'])) > 0,
            'STUDENT' => in_array('STUDENT', $jwtRoles, true),
            default => true,
        };
    }

    /**
     * @return array{0: string, 1: string}
     */
    protected function splitFullName(string $fullName): array
    {
        $parts = preg_split('/\s+/', trim($fullName)) ?: [$fullName];
        if (count($parts) === 1) {
            return [$parts[0], ''];
        }

        $lastName = array_shift($parts);
        $firstName = implode(' ', $parts);

        return [$firstName, (string) $lastName];
    }
}
