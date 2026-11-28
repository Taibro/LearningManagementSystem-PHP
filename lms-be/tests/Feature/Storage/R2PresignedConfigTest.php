<?php

use Illuminate\Support\Facades\Storage;

test('Cloudflare R2 disk and presigned URL defaults are configured properly', function () {
    $r2 = config('filesystems.disks.r2');
    $presigned = config('filesystems.presigned');

    expect($r2)->toBeArray()
        ->and($r2['driver'])->toBe('s3')
        ->and($r2['region'])->toBe('auto')
        ->and($r2['use_path_style_endpoint'])->toBeTrue()
        ->and($r2['visibility'])->toBe('private')
        ->and($r2['request_checksum_calculation'])->toBe('when_required')
        ->and($r2['response_checksum_validation'])->toBe('when_required')
        ->and($r2['throw'])->toBeTrue()
        ->and($presigned)->toBe([
            'disk' => 'r2',
            'upload_ttl_minutes' => 10,
            'download_ttl_minutes' => 15,
            'max_upload_size_mb' => 20,
        ]);
});

test('R2 disk generates SigV4 presigned PUT upload URLs using path-style endpoint', function () {
    config()->set('filesystems.disks.r2.key', 'test-access-key');
    config()->set('filesystems.disks.r2.secret', 'test-secret-key');
    config()->set('filesystems.disks.r2.bucket', 'lms-storage');
    config()->set('filesystems.disks.r2.endpoint', 'https://test-account.r2.cloudflarestorage.com');

    Storage::forgetDisk('r2');

    $uploadData = Storage::disk('r2')->temporaryUploadUrl(
        'schools/1/classes/5/materials/lecture.pdf',
        now()->addMinutes(10),
        ['ContentType' => 'application/pdf']
    );

    expect($uploadData)->toBeArray()
        ->toHaveKeys(['url', 'headers'])
        ->and($uploadData['url'])->toStartWith('https://test-account.r2.cloudflarestorage.com/lms-storage/schools/1/classes/5/materials/lecture.pdf?')
        ->and($uploadData['url'])->toContain('X-Amz-Algorithm=AWS4-HMAC-SHA256')
        ->and($uploadData['url'])->toContain('X-Amz-Signature=')
        ->and($uploadData['url'])->toContain('X-Amz-Expires=')
        ->and($uploadData['headers'])->toBeArray();
});

test('R2 disk generates SigV4 presigned GET download URLs with attachment disposition', function () {
    config()->set('filesystems.disks.r2.key', 'test-access-key');
    config()->set('filesystems.disks.r2.secret', 'test-secret-key');
    config()->set('filesystems.disks.r2.bucket', 'lms-storage');
    config()->set('filesystems.disks.r2.endpoint', 'https://test-account.r2.cloudflarestorage.com');

    Storage::forgetDisk('r2');

    $downloadUrl = Storage::disk('r2')->temporaryUrl(
        'schools/1/classes/5/materials/lecture.pdf',
        now()->addMinutes(15),
        ['ResponseContentDisposition' => 'attachment; filename="lecture.pdf"']
    );

    expect($downloadUrl)->toStartWith('https://test-account.r2.cloudflarestorage.com/lms-storage/schools/1/classes/5/materials/lecture.pdf?')
        ->and($downloadUrl)->toContain('X-Amz-Signature=')
        ->and($downloadUrl)->toContain('response-content-disposition=');
});
