<?php

namespace App\Http\Controllers\Auth;

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
use App\DTOs\Common\ErrorResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Auth\AuthCookieService;
use App\Services\Contracts\AuthServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use OpenApi\Attributes as OA;
use Throwable;

#[OA\Tag(name: 'Authentication', description: 'API endpoints for authentication and user sessions')]
class AuthController extends Controller
{
    private const AUTH_PREFIX = self::API_PREFIX . '/auth';

    public function __construct(
        private readonly AuthServiceInterface $authService,
        private readonly AuthCookieService $authCookieService,
    ) {}

    /**
     * GET /api/{version}/schools/active
     * Return active schools for the login/register dropdowns in lms-fe.
     */
    #[OA\Get(
        path: self::API_PREFIX . '/schools/active',
        operationId: 'getActiveSchools',
        tags: ['Authentication'],
        summary: 'Get active schools for tenant login dropdown',
        parameters: [
            new OA\Parameter(name: 'version', in: 'path', required: true, description: 'API version (e.g. v1)', schema: new OA\Schema(type: 'string', default: 'v1')),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'List of active schools',
                content: new OA\JsonContent(
                    type: 'array',
                    items: new OA\Items(ref: SchoolResponseDto::class)
                )
            ),
            new OA\Response(
                response: 500,
                description: 'Server error',
                content: new OA\JsonContent(ref: MessageResponseDto::class)
            ),
        ]
    )]
    public function activeSchools(): JsonResponse
    {
        try {
            return response()->json($this->authService->getActiveSchools());
        } catch (Throwable $e) {
            report($e);

            return response()->json(
                new MessageResponseDto('Không thể tải danh sách trường học.'),
                500
            );
        }
    }

    /**
     * POST /api/{version}/auth/login
     * Authenticate via Keycloak Direct Access Grant (no redirect to Keycloak UI).
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/login',
        operationId: 'authLogin',
        tags: ['Authentication'],
        summary: 'Log in user',
        description: 'Authenticate user with login code (student code, teacher code, username, or email) and password via Keycloak Direct Access Grant',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(ref: LoginRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Login successful with JWT access token',
                content: new OA\JsonContent(ref: AuthTokenResponseDto::class)
            ),
            new OA\Response(
                response: 401,
                description: 'Invalid credentials or tenant mismatch',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 422,
                description: 'Validation error',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 500,
                description: 'Keycloak connection error',
                content: new OA\JsonContent(ref: MessageResponseDto::class)
            ),
        ]
    )]
    public function login(Request $request): JsonResponse
    {
        $dto = LoginRequestDto::fromRequest($request);

        try {
            $result = $this->authService->login($dto);
            $response = response()->json($this->authCookieService->sanitizeAuthResponse($result, $request));

            return $this->authCookieService->attachAuthCookies(
                response: $response,
                accessToken: $result->accessToken,
                refreshToken: $result->refreshToken,
                expiresInSeconds: $result->expiresIn,
            );
        } catch (ValidationException $e) {
            $firstError = (string) (collect($e->errors())->flatten()->first() ?: 'Thông tin đăng nhập không hợp lệ.');

            return response()->json(
                new ErrorResponseDto(message: $firstError, errors: $e->errors()),
                401
            );
        } catch (Throwable $e) {
            report($e);

            return response()->json(
                new MessageResponseDto('Lỗi kết nối dịch vụ xác thực Keycloak: '.$e->getMessage()),
                500
            );
        }
    }

    /**
     * POST /api/{version}/auth/register
     * Register a new user in Keycloak and PostgreSQL via API.
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/register',
        operationId: 'authRegister',
        tags: ['Authentication'],
        summary: 'Register a new user',
        description: 'Register a new student/user in Keycloak and PostgreSQL database',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(ref: RegisterRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 201,
                description: 'User registered successfully',
                content: new OA\JsonContent(ref: AuthTokenResponseDto::class)
            ),
            new OA\Response(
                response: 422,
                description: 'Validation error',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 500,
                description: 'Server error',
                content: new OA\JsonContent(ref: MessageResponseDto::class)
            ),
        ]
    )]
    public function register(Request $request): JsonResponse
    {
        $dto = RegisterRequestDto::fromRequest($request);

        try {
            $result = $this->authService->register($dto);
            $response = response()->json($this->authCookieService->sanitizeAuthResponse($result, $request), 201);

            return $this->authCookieService->attachAuthCookies(
                response: $response,
                accessToken: $result->accessToken,
                refreshToken: $result->refreshToken,
                expiresInSeconds: $result->expiresIn,
            );
        } catch (ValidationException $e) {
            $firstError = (string) (collect($e->errors())->flatten()->first() ?: 'Dữ liệu đăng ký không hợp lệ.');

            return response()->json(
                new ErrorResponseDto(message: $firstError, errors: $e->errors()),
                422
            );
        } catch (Throwable $e) {
            report($e);

            return response()->json(
                new MessageResponseDto($e->getMessage() ?: 'Không thể đăng ký tài khoản.'),
                500
            );
        }
    }

    /**
     * POST /api/{version}/auth/refresh
     * Refresh Keycloak access token using refresh_token.
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/refresh',
        operationId: 'authRefresh',
        tags: ['Authentication'],
        summary: 'Refresh access token',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(ref: RefreshTokenRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Token refreshed successfully',
                content: new OA\JsonContent(ref: RefreshTokenResponseDto::class)
            ),
            new OA\Response(
                response: 401,
                description: 'Invalid or expired refresh token',
                content: new OA\JsonContent(ref: MessageResponseDto::class)
            ),
        ]
    )]
    public function refresh(Request $request): JsonResponse
    {
        $dto = RefreshTokenRequestDto::fromRequest($request);

        try {
            $result = $this->authService->refreshToken($dto);
            $response = response()->json($this->authCookieService->sanitizeRefreshResponse($result, $request));

            return $this->authCookieService->attachAuthCookies(
                response: $response,
                accessToken: $result->accessToken,
                refreshToken: $result->refreshToken,
                expiresInSeconds: $result->expiresIn,
            );
        } catch (ValidationException $e) {
            $firstError = (string) (collect($e->errors())->flatten()->first() ?: 'Phiên đăng nhập đã hết hạn.');

            return response()->json(
                new MessageResponseDto($firstError),
                401
            );
        }
    }

    /**
     * POST /api/{version}/auth/logout
     * Revoke Keycloak session.
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/logout',
        operationId: 'authLogout',
        tags: ['Authentication'],
        summary: 'Log out user',
        description: 'Revoke Keycloak session',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        security: [['bearerAuth' => []]],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(ref: LogoutRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Logged out successfully',
                content: new OA\JsonContent(ref: MessageResponseDto::class)
            ),
        ]
    )]
    public function logout(Request $request): JsonResponse
    {
        $dto = LogoutRequestDto::fromRequest($request);
        $response = response()->json($this->authService->logout($dto));

        return $this->authCookieService->clearAuthCookies($response);
    }

    /**
     * GET /api/{version}/auth/me
     * Return current authenticated user profile from Keycloak JWT + PostgreSQL.
     */
    #[OA\Get(
        path: self::AUTH_PREFIX . '/me',
        operationId: 'getAuthMe',
        tags: ['Authentication'],
        summary: 'Get current authenticated user profile',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(
                response: 200,
                description: 'User profile retrieved successfully',
                content: new OA\JsonContent(ref: UserProfileResponseDto::class)
            ),
            new OA\Response(
                response: 401,
                description: 'Unauthenticated',
                content: new OA\JsonContent(ref: MessageResponseDto::class)
            ),
        ]
    )]
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        return response()->json($this->authService->getCurrentUserProfile($user));
    }

    /**
     * POST /api/{version}/auth/2fa/setup
     * Provide QR code setup URI for 2FA modal compatibility in AdminLogin / SaaSAdminLogin.
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/2fa/setup',
        operationId: 'authSetup2fa',
        tags: ['Authentication'],
        summary: 'Generate 2FA QR code setup URI',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(ref: Setup2faRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'QR code setup URI generated successfully',
                content: new OA\JsonContent(ref: Setup2faResponseDto::class)
            ),
        ]
    )]
    public function setup2fa(Request $request): JsonResponse
    {
        $dto = Setup2faRequestDto::fromRequest($request);

        return response()->json($this->authService->setup2fa($dto));
    }

    /**
     * POST /api/{version}/auth/2fa/verify-setup
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/2fa/verify-setup',
        operationId: 'authVerifySetup2fa',
        tags: ['Authentication'],
        summary: 'Verify 2FA setup code',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(ref: Verify2faRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Whether the 6-digit verification code is valid',
                content: new OA\JsonContent(type: 'boolean')
            ),
        ]
    )]
    public function verifySetup2fa(Request $request): JsonResponse
    {
        $dto = Verify2faRequestDto::fromRequest($request);

        return response()->json($this->authService->verifySetup2fa($dto));
    }

    /**
     * POST /api/{version}/auth/login/verify-2fa
     */
    #[OA\Post(
        path: self::AUTH_PREFIX . '/login/verify-2fa',
        operationId: 'authVerifyLogin2fa',
        tags: ['Authentication'],
        summary: 'Verify 2FA code on login',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        security: [['bearerAuth' => []]],
        requestBody: new OA\RequestBody(
            required: false,
            content: new OA\JsonContent(ref: VerifyLogin2faRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: '2FA login verified successfully',
                content: new OA\JsonContent(ref: VerifyLogin2faResponseDto::class)
            ),
        ]
    )]
    public function verifyLogin2fa(Request $request): JsonResponse
    {
        $dto = VerifyLogin2faRequestDto::fromRequest($request);
        $user = $request->user('api');

        return response()->json($this->authService->verifyLogin2fa(
            dto: $dto,
            user: $user instanceof User ? $user : null,
            token: $this->authCookieService->extractAccessToken($request),
        ));
    }
}
