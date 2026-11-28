<?php

use App\Models\ImageUpload;
use App\Models\User;
use App\Repositories\Contracts\ImageUploadRepositoryInterface;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use Illuminate\Support\Facades\Storage;

function makeUploadActor(int $id = 10, int $schoolId = 1, string $role = 'STUDENT'): User
{
    $user = new User;
    $user->id = $id;
    $user->school_id = $schoolId;
    $user->full_name = 'Upload Tester';
    $user->email = 'upload.tester@huit.edu.vn';
    $user->is_active = true;
    $user->setAttribute('jwt_role', $role);
    $user->setAttribute('jwt_roles', [$role]);
    $user->setAttribute('jwt_school_id', $schoolId);

    return $user;
}

function fakeR2Storage(): void
{
    config([
        'filesystems.presigned.disk' => 'r2',
        'filesystems.presigned.upload_ttl_minutes' => 10,
        'filesystems.presigned.download_ttl_minutes' => 15,
        'filesystems.presigned.max_upload_size_mb' => 20,
        'filesystems.disks.r2.bucket' => 'lms-bucket',
        'filesystems.disks.r2.url' => 'https://cdn.example.r2.dev',
    ]);

    Storage::fake('r2');

    Storage::disk('r2')->buildTemporaryUrlsUsing(
        fn (string $path, DateTimeInterface $expiration, array $options = []): string => 'https://signed.r2.test/get/' . ltrim($path, '/') . '?disp=' . urlencode((string) ($options['ResponseContentDisposition'] ?? ''))
    );

    Storage::disk('r2')->buildTemporaryUploadUrlsUsing(
        fn (string $path, DateTimeInterface $expiration, array $options = []): array => [
            'url' => 'https://signed.r2.test/put/' . ltrim($path, '/'),
            'headers' => ['Content-Type' => (string) ($options['ContentType'] ?? 'application/octet-stream')],
        ]
    );
}

/**
 * Valid 1x1 PNG binary payload (real PNG magic bytes \x89PNG\r\n\x1a\n).
 */
function sampleValidPngBytes(): string
{
    return base64_decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+X2ZkAAAAASUVORK5CYII=',
        true
    ) ?: '';
}

it('creates a PENDING image_uploads record and returns a presigned PUT URL', function () {
    fakeR2Storage();

    $actor = makeUploadActor(10, 1);
    $repo = Mockery::mock(ImageUploadRepositoryInterface::class);
    $wrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $wrapper->shouldReceive('imageUploads')->andReturn($repo);

    $repo->shouldReceive('create')
        ->once()
        ->andReturnUsing(static function (array $data): ImageUpload {
            $record = new ImageUpload($data);
            $record->id = 42;

            return $record;
        });

    $this->app->instance(RepositoryWrapperInterface::class, $wrapper);

    $response = $this->actingAs($actor, 'api')
        ->postJson('/api/v1/uploads/presign', [
            'category' => 'AVATAR',
            'fileName' => 'avatar.png',
            'mimeType' => 'image/png',
            'fileSize' => 102400,
            'visibility' => 'PUBLIC',
        ]);

    $response->assertCreated()
        ->assertJsonPath('id', 42)
        ->assertJsonPath('category', 'AVATAR')
        ->assertJsonPath('method', 'PUT')
        ->assertJsonPath('status', 'PENDING')
        ->assertJsonPath('headers.Content-Type', 'image/png');

    expect($response->json('objectKey'))->toStartWith('schools/1/avatar/');
    expect($response->json('uploadUrl'))->toStartWith('https://signed.r2.test/put/schools/1/avatar/');
});

it('rejects disallowed mime type or oversized payload for AVATAR category', function () {
    fakeR2Storage();

    $actor = makeUploadActor(10, 1);

    $this->actingAs($actor, 'api')
        ->postJson('/api/v1/uploads/presign', [
            'category' => 'AVATAR',
            'fileName' => 'doc.pdf',
            'mimeType' => 'application/pdf',
            'fileSize' => 1024,
        ])
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['mimeType']);

    $this->actingAs($actor, 'api')
        ->postJson('/api/v1/uploads/presign', [
            'category' => 'AVATAR',
            'fileName' => 'huge.png',
            'mimeType' => 'image/png',
            'fileSize' => 6 * 1024 * 1024,
        ])
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['fileSize']);
});

it('confirms upload when magic bytes match valid PNG via league/mime-type-detection', function () {
    fakeR2Storage();

    $actor = makeUploadActor(10, 1);
    $objectKey = 'schools/1/avatar/2026/11/test-valid.png';
    Storage::disk('r2')->put($objectKey, sampleValidPngBytes());

    $pending = new ImageUpload([
        'image_uploads_id' => '11111111-1111-4111-8111-111111111111',
        'school_id' => 1,
        'uploaded_by' => 10,
        'disk' => 'r2',
        'bucket' => 'lms-bucket',
        'object_key' => $objectKey,
        'original_name' => 'avatar.png',
        'mime_type' => 'image/png',
        'file_size' => 100,
        'category' => ImageUpload::CATEGORY_AVATAR,
        'visibility' => ImageUpload::VISIBILITY_PUBLIC,
        'status' => ImageUpload::STATUS_PENDING,
    ]);
    $pending->id = 77;

    $repo = Mockery::mock(ImageUploadRepositoryInterface::class);
    $wrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $wrapper->shouldReceive('imageUploads')->andReturn($repo);

    $repo->shouldReceive('findByIdForSchool')->once()->with(77, 1)->andReturn($pending);
    $repo->shouldReceive('update')
        ->once()
        ->andReturnUsing(static function (ImageUpload $model, array $data): ImageUpload {
            $model->fill($data);

            return $model;
        });

    $this->app->instance(RepositoryWrapperInterface::class, $wrapper);

    $response = $this->actingAs($actor, 'api')
        ->postJson('/api/v1/uploads/77/confirm');

    $response->assertOk()
        ->assertJsonPath('id', 77)
        ->assertJsonPath('status', 'UPLOADED')
        ->assertJsonPath('mimeType', 'image/png')
        ->assertJsonPath('publicUrl', 'https://cdn.example.r2.dev/' . $objectKey);
});

it('rejects spoofed file whose magic bytes do not match allowed MIME, deletes it from R2, and marks FAILED', function () {
    fakeR2Storage();

    $actor = makeUploadActor(10, 1);
    $objectKey = 'schools/1/avatar/2026/11/spoofed.png';
    Storage::disk('r2')->put($objectKey, "<?php echo 'malicious'; ?>");

    $pending = new ImageUpload([
        'image_uploads_id' => '22222222-2222-4222-8222-222222222222',
        'school_id' => 1,
        'uploaded_by' => 10,
        'disk' => 'r2',
        'bucket' => 'lms-bucket',
        'object_key' => $objectKey,
        'original_name' => 'spoofed.png',
        'mime_type' => 'image/png',
        'file_size' => 27,
        'category' => ImageUpload::CATEGORY_AVATAR,
        'visibility' => ImageUpload::VISIBILITY_PRIVATE,
        'status' => ImageUpload::STATUS_PENDING,
    ]);
    $pending->id = 88;

    $repo = Mockery::mock(ImageUploadRepositoryInterface::class);
    $wrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $wrapper->shouldReceive('imageUploads')->andReturn($repo);

    $repo->shouldReceive('findByIdForSchool')->once()->with(88, 1)->andReturn($pending);
    $repo->shouldReceive('update')
        ->once()
        ->withArgs(static fn (ImageUpload $model, array $data): bool => $data['status'] === ImageUpload::STATUS_FAILED)
        ->andReturn($pending);

    $this->app->instance(RepositoryWrapperInterface::class, $wrapper);

    $this->actingAs($actor, 'api')
        ->postJson('/api/v1/uploads/88/confirm')
        ->assertUnprocessable()
        ->assertJsonValidationErrors(['file']);

    expect(Storage::disk('r2')->exists($objectKey))->toBeFalse();
});

it('returns a presigned GET download URL for a confirmed upload and enforces tenant isolation', function () {
    fakeR2Storage();

    $actorSchool1 = makeUploadActor(10, 1);
    $actorSchool2 = makeUploadActor(20, 2);

    $uploaded = new ImageUpload([
        'image_uploads_id' => '33333333-3333-4333-8333-333333333333',
        'school_id' => 1,
        'uploaded_by' => 10,
        'disk' => 'r2',
        'bucket' => 'lms-bucket',
        'object_key' => 'schools/1/class-material/2026/11/lecture.pdf',
        'original_name' => 'lecture.pdf',
        'mime_type' => 'application/pdf',
        'file_size' => 20480,
        'category' => ImageUpload::CATEGORY_CLASS_MATERIAL,
        'visibility' => ImageUpload::VISIBILITY_PRIVATE,
        'status' => ImageUpload::STATUS_UPLOADED,
    ]);
    $uploaded->id = 99;

    $repo = Mockery::mock(ImageUploadRepositoryInterface::class);
    $wrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $wrapper->shouldReceive('imageUploads')->andReturn($repo);

    $repo->shouldReceive('findByIdForSchool')->once()->with(99, 1)->andReturn($uploaded);
    $repo->shouldReceive('findByIdForSchool')->once()->with(99, 2)->andReturn(null);

    $this->app->instance(RepositoryWrapperInterface::class, $wrapper);

    $okResponse = $this->actingAs($actorSchool1, 'api')
        ->getJson('/api/v1/uploads/99/download-url?disposition=attachment');

    $okResponse->assertOk()
        ->assertJsonPath('id', 99)
        ->assertJsonPath('originalName', 'lecture.pdf')
        ->assertJsonPath('mimeType', 'application/pdf');

    expect($okResponse->json('downloadUrl'))->toContain('attachment');

    $this->actingAs($actorSchool2, 'api')
        ->getJson('/api/v1/uploads/99/download-url')
        ->assertNotFound();
});
