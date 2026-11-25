<?php

use App\DTOs\Auth\LogoutRequestDto;
use App\DTOs\Auth\RegisterRequestDto;
use App\DTOs\Auth\SchoolResponseDto;
use App\DTOs\Auth\Setup2faRequestDto;
use App\DTOs\Auth\Setup2faResponseDto;
use App\DTOs\Auth\UserProfileResponseDto;
use App\DTOs\Auth\Verify2faRequestDto;
use App\DTOs\Auth\VerifyLogin2faRequestDto;
use App\DTOs\Auth\VerifyLogin2faResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\Http\Controllers\Auth\AuthController;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Repositories\Contracts\SchoolRepositoryInterface;
use App\Services\Auth\AuthCookieService;
use App\Services\Auth\KeycloakAuthService;
use App\Services\Auth\KeycloakJwksService;
use App\Services\Contracts\AuthServiceInterface;
use Illuminate\Database\Eloquent\Collection as EloquentCollection;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;

test('AuthServiceInterface resolves to KeycloakAuthService via container', function () {
    $service = app(AuthServiceInterface::class);

    expect($service)->toBeInstanceOf(KeycloakAuthService::class);
});

test('AuthController only depends on AuthServiceInterface and AuthCookieService', function () {
    $reflection = new ReflectionClass(AuthController::class);
    $params = $reflection->getConstructor()?->getParameters() ?? [];

    expect($params)->toHaveCount(2);

    $firstType = $params[0]->getType();
    $secondType = $params[1]->getType();
    expect($firstType)->toBeInstanceOf(ReflectionNamedType::class)
        ->and($firstType->getName())->toBe(AuthServiceInterface::class)
        ->and($secondType)->toBeInstanceOf(ReflectionNamedType::class)
        ->and($secondType->getName())->toBe(AuthCookieService::class);
});

test('KeycloakAuthService maps active schools, user profile, logout, and 2FA DTOs', function () {
    $school = new School;
    $school->id = 1;
    $school->code = 'HUIT';
    $school->name = 'Trường ĐH Công Thương TP.HCM (HUIT)';

    $schoolRepo = Mockery::mock(SchoolRepositoryInterface::class);
    $schoolRepo->shouldReceive('getActiveSchools')
        ->once()
        ->andReturn(new EloquentCollection([$school]));

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('schools')
        ->once()
        ->andReturn($schoolRepo);

    $service = new KeycloakAuthService(
        jwksService: Mockery::mock(KeycloakJwksService::class),
        repositories: $repoWrapper,
    );

    $schools = $service->getActiveSchools();
    expect($schools)->toHaveCount(1)
        ->and($schools[0])->toBeInstanceOf(SchoolResponseDto::class)
        ->and($schools[0]->toArray())->toBe([
            'id' => 1,
            'value' => 'HUIT',
            'code' => 'HUIT',
            'label' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
            'name' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
        ]);

    $setup2fa = $service->setup2fa(new Setup2faRequestDto(email: 'admin@edusaas.io'));
    expect($setup2fa)->toBeInstanceOf(Setup2faResponseDto::class)
        ->and($setup2fa->qrCodeImageUri)->toContain('api.qrserver.com');

    expect($service->verifySetup2fa(new Verify2faRequestDto(code: '123456')))->toBeTrue()
        ->and($service->verifySetup2fa(new Verify2faRequestDto(code: '123')))->toBeFalse();

    $verifyLogin = $service->verifyLogin2fa(new VerifyLogin2faRequestDto(email: 'admin@huit.edu.vn'));
    expect($verifyLogin)->toBeInstanceOf(VerifyLogin2faResponseDto::class)
        ->and($verifyLogin->toArray())->toBe([
            'token' => null,
            'id' => null,
            'fullName' => 'Admin',
            'email' => 'admin@huit.edu.vn',
            'schoolId' => 1,
        ]);

    $logoutDto = $service->logout(new LogoutRequestDto);
    expect($logoutDto)->toBeInstanceOf(MessageResponseDto::class)
        ->and($logoutDto->message)->toBe('Đã đăng xuất thành công.');

    $student = new Student;
    $student->student_code = '2001230773';

    $user = new User;
    $user->id = 10;
    $user->users_id = 'a1b2c3d4-e5f6-4a1b-8c2d-3e4f5a6b7c8d';
    $user->keycloak_id = 'b4e5421a-4d23-455b-b996-2615462cf6ef';
    $user->full_name = 'Nguyễn Thành Tài';
    $user->email = 'ntai8448@gmail.com';
    $user->phone = '0901000005';
    $user->school_id = 1;
    $user->setAttribute('jwt_role', 'STUDENT');
    $user->setAttribute('jwt_roles', ['STUDENT']);
    $user->setRelation('school', $school);
    $user->setRelation('student', $student);
    $user->setRelation('teacher', null);

    $profile = $service->getCurrentUserProfile($user);
    expect($profile)->toBeInstanceOf(UserProfileResponseDto::class)
        ->and($profile->toArray())->toBe([
            'id' => 10,
            'userId' => 10,
            'usersId' => 'a1b2c3d4-e5f6-4a1b-8c2d-3e4f5a6b7c8d',
            'keycloakId' => 'b4e5421a-4d23-455b-b996-2615462cf6ef',
            'fullName' => 'Nguyễn Thành Tài',
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'avatarUrl' => null,
            'role' => 'STUDENT',
            'roles' => ['STUDENT'],
            'schoolId' => 1,
            'schoolCode' => 'HUIT',
            'schoolName' => 'Trường ĐH Công Thương TP.HCM (HUIT)',
            'studentCode' => '2001230773',
            'teacherCode' => null,
        ]);
});

test('AuthController delegates 2FA and logout endpoints cleanly to AuthServiceInterface', function () {
    $this->postJson('/api/v1/auth/2fa/setup', ['email' => 'admin@edusaas.io'])
        ->assertOk()
        ->assertJsonStructure(['qrCodeImageUri']);

    $this->postJson('/api/v1/auth/2fa/verify-setup', ['code' => '123456'])
        ->assertOk()
        ->assertContent('true');

    $this->postJson('/api/v1/auth/logout')
        ->assertOk()
        ->assertJson([
            'message' => 'Đã đăng xuất thành công.',
        ]);
});

test('RegisterRequestDto allows SAAS_ADMIN without school while non-SAAS roles require school', function () {
    $request = Request::create('/api/v1/auth/register', 'POST', [
        'fullName' => 'Super Admin 02',
        'email' => 'superadmin02@edusaas.io',
        'password' => 'Password@123',
        'userCode' => 'sa002',
        'userType' => 'SAAS_ADMIN',
    ]);

    $dto = RegisterRequestDto::fromRequest($request);
    expect($dto->userType)->toBe('SAAS_ADMIN')
        ->and($dto->school)->toBeNull();

    $service = new KeycloakAuthService(
        jwksService: Mockery::mock(KeycloakJwksService::class),
        repositories: Mockery::mock(RepositoryWrapperInterface::class),
    );

    expect(fn () => $service->register(new RegisterRequestDto(
        fullName: 'Sinh Vien A',
        email: 'sv@huit.edu.vn',
        password: 'Password@123',
        school: null,
        userType: 'STUDENT',
    )))->toThrow(ValidationException::class);
});
