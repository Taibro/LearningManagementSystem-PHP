<?php

namespace App\Services\Storage;

use App\DTOs\Storage\CreatePresignedUploadRequestDto;
use App\DTOs\Storage\PresignedDownloadRequestDto;
use App\DTOs\Storage\PresignedDownloadResponseDto;
use App\DTOs\Storage\PresignedUploadResponseDto;
use App\DTOs\Storage\UploadFileResponseDto;
use App\Models\ImageUpload;
use App\Models\User;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Services\Contracts\FileStorageServiceInterface;
use Illuminate\Filesystem\FilesystemAdapter;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use Illuminate\Validation\ValidationException;
use League\MimeTypeDetection\FinfoMimeTypeDetector;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\ConflictHttpException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class R2FileStorageService implements FileStorageServiceInterface
{
    private const MAGIC_BYTES_SAMPLE_LENGTH = 8192;

    /** @var array<int, string> */
    private const OOXML_MIMES = [
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ];

    /** @var array<string, array{mimes: array<int, string>, max_mb: int}> */
    private const CATEGORY_POLICIES = [
        ImageUpload::CATEGORY_AVATAR => [
            'mimes' => ['image/jpeg', 'image/png', 'image/webp'],
            'max_mb' => 5,
        ],
        ImageUpload::CATEGORY_SCHOOL_LOGO => [
            'mimes' => ['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml'],
            'max_mb' => 5,
        ],
        ImageUpload::CATEGORY_CLASS_MATERIAL => [
            'mimes' => [
                'application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.ms-powerpoint',
                'application/vnd.openxmlformats-officedocument.presentationml.presentation',
                'application/vnd.ms-excel',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                'application/zip',
                'image/jpeg',
                'image/png',
                'image/webp',
            ],
            'max_mb' => 20,
        ],
        ImageUpload::CATEGORY_TEACHER_EVIDENCE => [
            'mimes' => ['application/pdf', 'image/jpeg', 'image/png', 'image/webp'],
            'max_mb' => 10,
        ],
        ImageUpload::CATEGORY_GENERAL => [
            'mimes' => [
                'image/jpeg',
                'image/png',
                'image/webp',
                'application/pdf',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            ],
            'max_mb' => 20,
        ],
    ];

    public function __construct(
        private readonly RepositoryWrapperInterface $repositories,
    ) {}

    public function createPresignedUpload(User $user, CreatePresignedUploadRequestDto $dto): PresignedUploadResponseDto
    {
        $this->assertCategoryPolicy($dto);

        $schoolId = $this->resolveSchoolId($user);
        $diskName = (string) config('filesystems.presigned.disk', 'r2');
        $disk = $this->resolveAdapter($diskName);
        $bucket = (string) config("filesystems.disks.{$diskName}.bucket", '');
        $ttlMinutes = max(1, (int) config('filesystems.presigned.upload_ttl_minutes', 10));
        $expiresAt = now()->addMinutes($ttlMinutes);

        $uploadUuid = Str::uuid()->toString();
        $objectKey = $this->buildObjectKey($schoolId, $dto->category, $uploadUuid, $dto->fileName, $dto->mimeType);

        /** @var array{url: string, headers: array<string, array<int, string>|string>} $signed */
        $signed = $disk->temporaryUploadUrl($objectKey, $expiresAt, [
            'ContentType' => $dto->mimeType,
        ]);

        $record = $this->repositories->imageUploads()->create([
            'image_uploads_id' => $uploadUuid,
            'school_id' => $schoolId,
            'uploaded_by' => (int) $user->id,
            'disk' => $diskName,
            'bucket' => $bucket !== '' ? $bucket : $diskName,
            'object_key' => $objectKey,
            'original_name' => $this->sanitizeOriginalName($dto->fileName),
            'mime_type' => $dto->mimeType,
            'file_size' => $dto->fileSize,
            'category' => $dto->category,
            'visibility' => $dto->visibility,
            'status' => ImageUpload::STATUS_PENDING,
            'expires_at' => $expiresAt,
            'created_by' => (int) $user->id,
            'updated_by' => (int) $user->id,
        ]);

        $headers = $signed['headers'];
        if (! array_key_exists('Content-Type', $headers) && ! array_key_exists('content-type', $headers)) {
            $headers['Content-Type'] = $dto->mimeType;
        }

        return new PresignedUploadResponseDto(
            id: (int) $record->id,
            uploadId: (string) $record->image_uploads_id,
            category: (string) $record->category,
            objectKey: (string) $record->object_key,
            uploadUrl: (string) $signed['url'],
            method: 'PUT',
            headers: $headers,
            expiresAt: $expiresAt->toIso8601String(),
            status: (string) $record->status,
        );
    }

    public function confirmUpload(User $user, int $uploadId): UploadFileResponseDto
    {
        $schoolId = $this->resolveSchoolId($user);
        $record = $this->repositories->imageUploads()->findByIdForSchool($uploadId, $schoolId);

        if ($record === null) {
            throw new NotFoundHttpException('Không tìm thấy bản ghi tệp tải lên.');
        }

        if ($record->uploaded_by !== null && (int) $record->uploaded_by !== (int) $user->id && ! $this->isAdmin($user)) {
            throw new AccessDeniedHttpException('Bạn không có quyền xác nhận tệp tải lên này.');
        }

        if ($record->status === ImageUpload::STATUS_UPLOADED) {
            return $this->mapToUploadFileResponseDto($record);
        }

        $disk = $this->resolveAdapter((string) $record->disk);
        $objectKey = (string) $record->object_key;
        if (! $disk->exists($objectKey)) {
            throw new ConflictHttpException('Tệp chưa tồn tại trên kho lưu trữ R2. Vui lòng hoàn tất bước PUT lên presigned URL trước khi xác nhận.');
        }

        $resolvedMime = $this->verifyMagicBytesOrFail($disk, $record, (int) $user->id);
        $actualSize = $disk->size($objectKey);

        /** @var ImageUpload $updated */
        $updated = $this->repositories->imageUploads()->update($record, [
            'status' => ImageUpload::STATUS_UPLOADED,
            'mime_type' => $resolvedMime,
            'file_size' => $actualSize > 0 ? $actualSize : $record->file_size,
            'uploaded_at' => now(),
            'updated_by' => (int) $user->id,
        ]);

        return $this->mapToUploadFileResponseDto($updated);
    }

    public function createPresignedDownload(
        User $user,
        int $uploadId,
        PresignedDownloadRequestDto $dto
    ): PresignedDownloadResponseDto {
        $schoolId = $this->resolveSchoolId($user);
        $record = $this->repositories->imageUploads()->findByIdForSchool($uploadId, $schoolId);

        if ($record === null) {
            throw new NotFoundHttpException('Không tìm thấy tệp yêu cầu.');
        }

        if ($record->status !== ImageUpload::STATUS_UPLOADED) {
            throw new ConflictHttpException('Tệp chưa hoàn tất tải lên nên chưa thể tạo đường dẫn tải xuống.');
        }

        $disk = $this->resolveAdapter((string) $record->disk);
        $ttlMinutes = max(1, (int) config('filesystems.presigned.download_ttl_minutes', 15));
        $expiresAt = now()->addMinutes($ttlMinutes);
        $safeFileName = str_replace(['"', '\\', "\r", "\n"], '', (string) $record->original_name);

        $downloadUrl = $disk->temporaryUrl((string) $record->object_key, $expiresAt, [
            'ResponseContentType' => (string) $record->mime_type,
            'ResponseContentDisposition' => sprintf('%s; filename="%s"', $dto->disposition, $safeFileName),
        ]);

        return new PresignedDownloadResponseDto(
            id: (int) $record->id,
            uploadId: (string) $record->image_uploads_id,
            originalName: (string) $record->original_name,
            mimeType: (string) $record->mime_type,
            fileSize: (int) $record->file_size,
            downloadUrl: $downloadUrl,
            expiresAt: $expiresAt->toIso8601String(),
        );
    }

    public function deleteUpload(User $user, int $uploadId): void
    {
        $schoolId = $this->resolveSchoolId($user);
        $record = $this->repositories->imageUploads()->findByIdForSchool($uploadId, $schoolId);

        if ($record === null) {
            throw new NotFoundHttpException('Không tìm thấy tệp cần xóa.');
        }

        if ($record->uploaded_by !== null && (int) $record->uploaded_by !== (int) $user->id && ! $this->isAdmin($user)) {
            throw new AccessDeniedHttpException('Bạn không có quyền xóa tệp này.');
        }

        $disk = $this->resolveAdapter((string) $record->disk);
        if ($disk->exists((string) $record->object_key)) {
            $disk->delete((string) $record->object_key);
        }

        $this->repositories->imageUploads()->delete($record);
    }

    /**
     * Inspect magic bytes using league/mime-type-detection (FinfoMimeTypeDetector).
     * Rejects spoofed/disallowed content, deletes the object from R2, and marks the record FAILED.
     */
    private function verifyMagicBytesOrFail(FilesystemAdapter $disk, ImageUpload $record, int $actorId): string
    {
        $objectKey = (string) $record->object_key;
        $buffer = $this->readMagicBytesSample($disk, $objectKey);
        $detector = new FinfoMimeTypeDetector;
        $detectedMime = $detector->detectMimeTypeFromBuffer($buffer);

        $category = (string) $record->category;
        $declaredMime = strtolower((string) $record->mime_type);
        $policy = self::CATEGORY_POLICIES[$category] ?? self::CATEGORY_POLICIES[ImageUpload::CATEGORY_GENERAL];
        $allowedMimes = $policy['mimes'];

        $resolvedMime = $this->resolveVerifiedMime($detectedMime, $declaredMime, $allowedMimes, $buffer);
        if ($resolvedMime !== null) {
            return $resolvedMime;
        }

        $disk->delete($objectKey);
        $this->repositories->imageUploads()->update($record, [
            'status' => ImageUpload::STATUS_FAILED,
            'updated_by' => $actorId,
        ]);

        throw ValidationException::withMessages([
            'file' => [
                sprintf(
                    'Nội dung tệp thực tế (%s) không hợp lệ hoặc không được phép cho danh mục %s.',
                    $detectedMime ?? 'unknown',
                    $category
                ),
            ],
        ]);
    }

    /**
     * @param  array<int, string>  $allowedMimes
     */
    private function resolveVerifiedMime(?string $detectedMime, string $declaredMime, array $allowedMimes, string $buffer): ?string
    {
        if ($detectedMime === null || $detectedMime === '') {
            return null;
        }

        $normalizedDetected = strtolower($detectedMime);

        if (in_array($normalizedDetected, $allowedMimes, true)) {
            return $normalizedDetected;
        }

        // Office Open XML (.docx/.xlsx/.pptx) shares ZIP magic bytes (PK\x03\x04)
        if (
            $normalizedDetected === 'application/zip'
            && in_array($declaredMime, self::OOXML_MIMES, true)
            && in_array($declaredMime, $allowedMimes, true)
        ) {
            return $declaredMime;
        }

        // SVG files may be detected as text/xml or application/xml by finfo
        if (
            $declaredMime === 'image/svg+xml'
            && in_array('image/svg+xml', $allowedMimes, true)
            && in_array($normalizedDetected, ['text/xml', 'application/xml', 'text/plain'], true)
            && stripos($buffer, '<svg') !== false
        ) {
            return 'image/svg+xml';
        }

        return null;
    }

    private function readMagicBytesSample(FilesystemAdapter $disk, string $objectKey): string
    {
        $stream = $disk->readStream($objectKey);
        if (is_resource($stream)) {
            try {
                $chunk = fread($stream, self::MAGIC_BYTES_SAMPLE_LENGTH);

                return is_string($chunk) ? $chunk : '';
            } finally {
                fclose($stream);
            }
        }

        $content = $disk->get($objectKey);

        return is_string($content) ? substr($content, 0, self::MAGIC_BYTES_SAMPLE_LENGTH) : '';
    }

    private function assertCategoryPolicy(CreatePresignedUploadRequestDto $dto): void
    {
        $policy = self::CATEGORY_POLICIES[$dto->category] ?? self::CATEGORY_POLICIES[ImageUpload::CATEGORY_GENERAL];
        $globalMaxMb = max(1, (int) config('filesystems.presigned.max_upload_size_mb', 20));
        $effectiveMaxMb = min($policy['max_mb'], $globalMaxMb);

        if (! in_array($dto->mimeType, $policy['mimes'], true)) {
            throw ValidationException::withMessages([
                'mimeType' => ['Định dạng tệp không được hỗ trợ cho danh mục ' . $dto->category . '.'],
            ]);
        }

        if ($dto->fileSize > $effectiveMaxMb * 1024 * 1024) {
            throw ValidationException::withMessages([
                'fileSize' => ['Dung lượng tệp vượt quá giới hạn tối đa ' . $effectiveMaxMb . ' MB cho danh mục ' . $dto->category . '.'],
            ]);
        }
    }

    private function resolveSchoolId(User $user): int
    {
        return (int) ($user->getAttribute('jwt_school_id') ?: $user->school_id);
    }

    private function isAdmin(User $user): bool
    {
        $role = strtoupper((string) ($user->getAttribute('jwt_role') ?: ''));
        $roles = array_map(
            static fn (mixed $item): string => strtoupper((string) $item),
            is_array($user->getAttribute('jwt_roles')) ? $user->getAttribute('jwt_roles') : []
        );

        return in_array($role, ['SCHOOL_ADMIN', 'SAAS_ADMIN'], true)
            || in_array('SCHOOL_ADMIN', $roles, true)
            || in_array('SAAS_ADMIN', $roles, true);
    }

    private function resolveAdapter(string $diskName): FilesystemAdapter
    {
        return Storage::disk($diskName);
    }

    private function buildObjectKey(
        int $schoolId,
        string $category,
        string $uploadUuid,
        string $originalName,
        string $mimeType
    ): string {
        $categorySlug = Str::slug(strtolower($category), '-');
        $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        $extension = preg_replace('/[^a-z0-9]/', '', $extension) ?? '';

        if ($extension === '') {
            $extension = match ($mimeType) {
                'image/jpeg' => 'jpg',
                'image/png' => 'png',
                'image/webp' => 'webp',
                'image/svg+xml' => 'svg',
                'application/pdf' => 'pdf',
                default => 'bin',
            };
        }

        return sprintf(
            'schools/%d/%s/%s/%s.%s',
            $schoolId,
            $categorySlug,
            now()->format('Y/m'),
            $uploadUuid,
            $extension
        );
    }

    private function sanitizeOriginalName(string $fileName): string
    {
        $base = basename(str_replace('\\', '/', $fileName));

        return Str::limit($base !== '' ? $base : 'file', 255, '');
    }

    private function mapToUploadFileResponseDto(ImageUpload $record): UploadFileResponseDto
    {
        return new UploadFileResponseDto(
            id: (int) $record->id,
            uploadId: (string) $record->image_uploads_id,
            category: (string) $record->category,
            visibility: (string) $record->visibility,
            status: (string) $record->status,
            objectKey: (string) $record->object_key,
            originalName: (string) $record->original_name,
            mimeType: (string) $record->mime_type,
            fileSize: (int) $record->file_size,
            publicUrl: $record->resolvePublicUrl(),
            uploadedAt: $record->uploaded_at?->toIso8601String(),
        );
    }
}
