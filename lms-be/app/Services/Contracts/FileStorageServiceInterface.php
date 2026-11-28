<?php

namespace App\Services\Contracts;

use App\DTOs\Storage\CreatePresignedUploadRequestDto;
use App\DTOs\Storage\PresignedDownloadRequestDto;
use App\DTOs\Storage\PresignedDownloadResponseDto;
use App\DTOs\Storage\PresignedUploadResponseDto;
use App\DTOs\Storage\UploadFileResponseDto;
use App\Models\User;

interface FileStorageServiceInterface
{
    /**
     * Validate upload metadata, create a PENDING ImageUpload record, and return a presigned R2 PUT URL.
     */
    public function createPresignedUpload(User $user, CreatePresignedUploadRequestDto $dto): PresignedUploadResponseDto;

    /**
     * Verify the uploaded object exists on R2, inspect magic bytes via league/mime-type-detection, and mark as UPLOADED.
     */
    public function confirmUpload(User $user, int $uploadId): UploadFileResponseDto;

    /**
     * Generate a temporary presigned R2 GET URL for a confirmed ImageUpload record within the user's tenant.
     */
    public function createPresignedDownload(
        User $user,
        int $uploadId,
        PresignedDownloadRequestDto $dto
    ): PresignedDownloadResponseDto;

    /**
     * Delete the object from R2 and remove its ImageUpload record (cascading SET NULL on referencing FKs).
     */
    public function deleteUpload(User $user, int $uploadId): void;
}
