<?php

namespace App\DTOs\Common;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'ErrorResponseDto',
    title: 'Error Response',
    description: 'Standard validation or authentication error response payload',
)]
final class ErrorResponseDto implements JsonSerializable
{
    /**
     * @param  array<string, array<int, string>>|null  $errors
     */
    public function __construct(
        #[OA\Property]
        public readonly string $message,

        #[OA\Property(
            type: 'object',
            nullable: true,
            additionalProperties: new OA\AdditionalProperties(
                type: 'array',
                items: new OA\Items(type: 'string')
            )
        )]
        public readonly ?array $errors = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $requestId = null,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        $payload = ['message' => $this->message];

        if ($this->errors !== null) {
            $payload['errors'] = $this->errors;
        }

        if ($this->requestId !== null) {
            $payload['requestId'] = $this->requestId;
        }

        return $payload;
    }

    /**
     * @return array<string, mixed>
     */
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
}
