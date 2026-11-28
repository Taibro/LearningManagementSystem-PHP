<?php

namespace App\DTOs\Storage;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'PresignedDownloadResponseDto',
    title: 'Presigned Download Response',
    description: 'Temporary Cloudflare R2 GET presigned URL for downloading or viewing a file',
)]
final class PresignedDownloadResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly int $id,

        #[OA\Property]
        public readonly string $uploadId,

        #[OA\Property]
        public readonly string $originalName,

        #[OA\Property]
        public readonly string $mimeType,

        #[OA\Property]
        public readonly int $fileSize,

        #[OA\Property]
        public readonly string $downloadUrl,

        #[OA\Property(description: 'ISO-8601 expiration timestamp of the presigned GET URL')]
        public readonly string $expiresAt,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'uploadId' => $this->uploadId,
            'originalName' => $this->originalName,
            'mimeType' => $this->mimeType,
            'fileSize' => $this->fileSize,
            'downloadUrl' => $this->downloadUrl,
            'expiresAt' => $this->expiresAt,
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
