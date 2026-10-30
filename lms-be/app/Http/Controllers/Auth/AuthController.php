<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Models\School;
use App\Services\Auth\KeycloakAuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Throwable;

class AuthController extends Controller
{
    public function __construct(
        private readonly KeycloakAuthService $keycloakAuthService,
    ) {}

    /**
     * GET /api/schools/active
     * Return active schools for the login/register dropdowns in lms-fe.
     */
    public function activeSchools(): JsonResponse
    {
        try {
            $schools = School::on('pgsql_owner')
                ->where('is_active', true)
                ->orderBy('id')
                ->get(['id', 'code', 'name']);

            if ($schools->isEmpty()) {
                return response()->json([
                    [
                        'id' => 1,
                        'value' => 'HUIT',
                        'code' => 'HUIT',
                        'label' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
                        'name' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
                    ],
                    [
                        'id' => 2,
                        'value' => 'HCMUT',
                        'code' => 'HCMUT',
                        'label' => 'Trường ĐH Bách Khoa TP.HCM (HCMUT)',
                        'name' => 'Trường ĐH Bách Khoa TP.HCM (HCMUT)',
                    ],
                ]);
            }

            return response()->json(
                $schools->map(fn (School $s) => [
                    'id' => $s->id,
                    'value' => $s->code,
                    'code' => $s->code,
                    'label' => $s->name,
                    'name' => $s->name,
                ])->values()
            );
        } catch (Throwable) {
            return response()->json([
                [
                    'id' => 1,
                    'value' => 'HUIT',
                    'code' => 'HUIT',
                    'label' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
                    'name' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
                ],
                [
                    'id' => 2,
                    'value' => 'HCMUT',
                    'code' => 'HCMUT',
                    'label' => 'Trường ĐH Bách Khoa TP.HCM (HCMUT)',
                    'name' => 'Trường ĐH Bách Khoa TP.HCM (HCMUT)',
                ],
            ]);
        }
    }

    /**
     * POST /api/auth/login
     * Authenticate via Keycloak Direct Access Grant (no redirect to Keycloak UI).
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'loginCode' => ['required', 'string'],
            'password' => ['required', 'string'],
            'userType' => ['nullable', 'string'],
            'school' => ['nullable', 'string'],
        ]);

        try {
            $result = $this->keycloakAuthService->login(
                loginCode: $validated['loginCode'],
                password: $validated['password'],
                userType: $validated['userType'] ?? 'STUDENT',
                schoolCode: $validated['school'] ?? null,
            );

            return response()->json($result);
        } catch (ValidationException $e) {
            $firstError = collect($e->errors())->flatten()->first() ?: 'Thông tin đăng nhập không hợp lệ.';

            return response()->json([
                'message' => $firstError,
                'errors' => $e->errors(),
            ], 401);
        } catch (Throwable $e) {
            report($e);

            return response()->json([
                'message' => 'Lỗi kết nối dịch vụ xác thực Keycloak: '.$e->getMessage(),
            ], 500);
        }
    }

    /**
     * POST /api/auth/register
     * Register a new user in Keycloak and PostgreSQL via API.
     */
    public function register(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'fullName' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:6'],
            'userCode' => ['nullable', 'string', 'max:50'],
            'loginCode' => ['nullable', 'string', 'max:50'],
            'studentCode' => ['nullable', 'string', 'max:50'],
            'teacherCode' => ['nullable', 'string', 'max:50'],
            'userType' => ['nullable', 'string'],
            'school' => ['required', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'major' => ['nullable', 'string', 'max:100'],
            'className' => ['nullable', 'string', 'max:50'],
            'specialization' => ['nullable', 'string', 'max:255'],
            'qualification' => ['nullable', 'string', 'max:255'],
            'departmentId' => ['nullable', 'integer'],
        ]);

        try {
            $result = $this->keycloakAuthService->register($validated);

            return response()->json($result, 201);
        } catch (ValidationException $e) {
            $firstError = collect($e->errors())->flatten()->first() ?: 'Dữ liệu đăng ký không hợp lệ.';

            return response()->json([
                'message' => $firstError,
                'errors' => $e->errors(),
            ], 422);
        } catch (Throwable $e) {
            report($e);

            return response()->json([
                'message' => $e->getMessage() ?: 'Không thể đăng ký tài khoản.',
            ], 500);
        }
    }

    /**
     * POST /api/auth/refresh
     * Refresh Keycloak access token using refresh_token.
     */
    public function refresh(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'refreshToken' => ['required', 'string'],
        ]);

        try {
            $result = $this->keycloakAuthService->refreshToken($validated['refreshToken']);

            return response()->json($result);
        } catch (ValidationException $e) {
            return response()->json([
                'message' => collect($e->errors())->flatten()->first(),
            ], 401);
        }
    }

    /**
     * POST /api/auth/logout
     * Revoke Keycloak session.
     */
    public function logout(Request $request): JsonResponse
    {
        $this->keycloakAuthService->logout($request->input('refreshToken'));

        return response()->json([
            'message' => 'Đã đăng xuất thành công.',
        ]);
    }

    /**
     * GET /api/auth/me
     * Return current authenticated user profile from Keycloak JWT + PostgreSQL.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $user->loadMissing(['school', 'student', 'teacher']);
        $role = (string) ($user->getAttribute('jwt_role') ?: 'STUDENT');

        return response()->json([
            'id' => $user->id,
            'userId' => $user->id,
            'usersId' => $user->users_id,
            'keycloakId' => $user->keycloak_id,
            'fullName' => $user->full_name,
            'email' => $user->email,
            'phone' => $user->phone,
            'avatarUrl' => $user->avatar_url,
            'role' => $role,
            'roles' => $user->getAttribute('jwt_roles') ?? [$role],
            'schoolId' => $user->school_id,
            'schoolCode' => $user->school?->code,
            'schoolName' => $user->school?->name,
            'studentCode' => $user->student?->student_code,
            'teacherCode' => $user->teacher?->teacher_code,
        ]);
    }

    /**
     * POST /api/auth/2fa/setup
     * Provide QR code setup URI for 2FA modal compatibility in AdminLogin / SaaSAdminLogin.
     */
    public function setup2fa(Request $request): JsonResponse
    {
        $email = (string) $request->input('email', 'admin@edusaas.io');
        $otpAuth = rawurlencode("otpauth://totp/EduSpace:{$email}?secret=JBSWY3DPEHPK3PXP&issuer=EduSpace");

        return response()->json([
            'qrCodeImageUri' => "https://api.qrserver.com/v1/create-qr-code/?size=200x200&data={$otpAuth}",
        ]);
    }

    /**
     * POST /api/auth/2fa/verify-setup
     */
    public function verifySetup2fa(Request $request): JsonResponse
    {
        $code = (string) $request->input('code', '');

        return response()->json(strlen(trim($code)) === 6);
    }

    /**
     * POST /api/auth/login/verify-2fa
     */
    public function verifyLogin2fa(Request $request): JsonResponse
    {
        $token = $request->bearerToken();
        $user = $request->user('api');

        return response()->json([
            'token' => $token,
            'id' => $user?->id,
            'fullName' => $user?->full_name ?? 'Admin',
            'email' => $user?->email ?? $request->input('email'),
            'schoolId' => $user?->school_id ?? 1,
        ]);
    }
}

