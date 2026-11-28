<?php

namespace App\DTOs\Storage;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'PresignedUploadResponseDto',
    title: 'Presigned Upload Response',
    description: 'Presigned PUT URL and metadata record created in PENDING state',
)]
final class PresignedUploadResponseDto implements JsonSerializable
{
    /**
     * @param  array<string, array<int, string>|string>  $headers
     */
    public function __construct(
        #[OA\Property]
        public readonly int $id,

        #[OA\Property(description: 'Public UUID of the image_uploads record')]
        public readonly string $uploadId,

        #[OA\Property]
        public readonly string $category,

        #[OA\Property]
        public readonly string $objectKey,

        #[OA\Property]
        public readonly string $uploadUrl,

        #[OA\Property(description: 'HTTP method to upload directly to R2 (PUT)')]
        public readonly string $method,

        #[OA\Property(
            type: 'object',
            additionalProperties: true,
            description: 'Required HTTP headers to send with the PUT request to R2'
        )]
        public readonly array $headers,

        #[OA\Property(description: 'ISO-8601 expiration timestamp of the presigned URL')]
        public readonly string $expiresAt,

        #[OA\Property]
        public readonly string $status,
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
            'objectKey' => $this->objectKey,
            'uploadUrl' => $this->uploadUrl,
            'method' => $this->method,
            'headers' => $this->headers,
            'expiresAt' => $this->expiresAt,
            'status' => $this->status,
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
