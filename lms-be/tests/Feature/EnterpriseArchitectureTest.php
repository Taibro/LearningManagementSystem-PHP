<?php

use App\DTOs\Common\PagedResultDto;
use App\Repositories\Contracts\ImageUploadRepositoryInterface;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Repositories\Contracts\RoleRepositoryInterface;
use App\Repositories\Contracts\SchoolRepositoryInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use App\Repositories\Contracts\TeacherRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Repositories\Contracts\UserRoleRepositoryInterface;
use App\Repositories\Eloquent\BaseRepository;
use App\Repositories\Eloquent\RepositoryWrapper;

test('RepositoryWrapperInterface resolves as scoped Unit of Work and lazy-loads all repositories', function () {
    $wrapperA = app(RepositoryWrapperInterface::class);
    $wrapperB = app(RepositoryWrapperInterface::class);

    expect($wrapperA)->toBeInstanceOf(RepositoryWrapper::class)
        ->and($wrapperA)->toBe($wrapperB);

    expect($wrapperA->schools())->toBeInstanceOf(SchoolRepositoryInterface::class)
        ->and($wrapperA->schools())->toBe($wrapperA->schools())
        ->and($wrapperA->users())->toBeInstanceOf(UserRepositoryInterface::class)
        ->and($wrapperA->roles())->toBeInstanceOf(RoleRepositoryInterface::class)
        ->and($wrapperA->userRoles())->toBeInstanceOf(UserRoleRepositoryInterface::class)
        ->and($wrapperA->students())->toBeInstanceOf(StudentRepositoryInterface::class)
        ->and($wrapperA->teachers())->toBeInstanceOf(TeacherRepositoryInterface::class)
        ->and($wrapperA->imageUploads())->toBeInstanceOf(ImageUploadRepositoryInterface::class);
});

test('All repositories default to null (RLS) connection and asSystemOwner scopes override safely', function () {
    $wrapper = app(RepositoryWrapperInterface::class);

    foreach ([
        $wrapper->schools(),
        $wrapper->users(),
        $wrapper->roles(),
        $wrapper->userRoles(),
        $wrapper->students(),
        $wrapper->teachers(),
        $wrapper->imageUploads(),
    ] as $repo) {
        $prop = new ReflectionProperty($repo, 'connection');
        expect($prop->getValue($repo))->toBeNull();
    }

    config(['database.default' => 'pgsql']);
    expect(BaseRepository::currentConnectionOverride())->toBeNull();

    $inside = $wrapper->asSystemOwner(fn () => BaseRepository::currentConnectionOverride());
    expect($inside)->toBe('pgsql_owner')
        ->and(BaseRepository::currentConnectionOverride())->toBeNull();
});

test('PagedResultDto serializes to standardized enterprise pagination structure', function () {
    $dto = new PagedResultDto(
        items: [['id' => 1], ['id' => 2]],
        totalCount: 25,
        pageNumber: 2,
        pageSize: 10,
        totalPages: 3,
    );

    expect($dto->jsonSerialize())->toBe([
        'items' => [['id' => 1], ['id' => 2]],
        'totalCount' => 25,
        'pageNumber' => 2,
        'pageSize' => 10,
        'totalPages' => 3,
    ]);
});

test('API responses include X-Request-Id and enterprise security headers', function () {
    $response = $this->getJson('/api/v1/health');

    expect($response->getStatusCode())->toBeIn([200, 503]);

    $response->assertHeader('X-Frame-Options', 'DENY')
        ->assertHeader('X-Content-Type-Options', 'nosniff')
        ->assertHeader('Referrer-Policy', 'strict-origin-when-cross-origin')
        ->assertJsonStructure([
            'status',
            'timestamp',
            'checks' => ['app', 'database', 'cache'],
        ]);

    expect($response->headers->get('X-Request-Id'))->not->toBeEmpty();
});

test('Unknown API route returns standardized JSON error with requestId', function () {
    $response = $this->getJson('/api/v1/does-not-exist', [
        'X-Request-Id' => 'test-trace-id-123',
    ]);

    $response->assertStatus(404)
        ->assertHeader('X-Request-Id', 'test-trace-id-123')
        ->assertJson([
            'message' => 'Không tìm thấy tài nguyên hoặc endpoint yêu cầu.',
            'requestId' => 'test-trace-id-123',
        ]);
});

test('Unauthenticated API request without Accept json header returns 401 instead of 500 Route login not defined', function () {
    $this->get('/api/v1/uploads/1/download-url', [
        'Accept' => '*/*',
    ])->assertStatus(401)
        ->assertJsonStructure(['message', 'requestId']);
});
