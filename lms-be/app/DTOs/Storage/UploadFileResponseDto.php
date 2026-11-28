<?php

namespace App\DTOs\Storage;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'UploadFileResponseDto',
    title: 'Upload File Response',
    description: 'Confirmed uploaded file metadata stored in image_uploads',
)]
final class UploadFileResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly int $id,

        #[OA\Property]
        public readonly string $uploadId,

        #[OA\Property]
        public readonly string $category,

        #[OA\Property]
        public readonly string $visibility,

        #[OA\Property]
        public readonly string $status,

        #[OA\Property]
        public readonly string $objectKey,

        #[OA\Property]
        public readonly string $originalName,

        #[OA\Property]
        public readonly string $mimeType,

        #[OA\Property]
        public readonly int $fileSize,

        #[OA\Property(nullable: true)]
        public readonly ?string $publicUrl,

        #[OA\Property(nullable: true)]
        public readonly ?string $uploadedAt,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'uploadId' => $this->uploadId,
            'category' => $this->category,
            'visibility' => $this->visibility,
            'status' => $this->status,
            'objectKey' => $this->objectKey,
            'originalName' => $this->originalName,
            'mimeType' => $this->mimeType,
            'fileSize' => $this->fileSize,
            'publicUrl' => $this->publicUrl,
            'uploadedAt' => $this->uploadedAt,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
}
