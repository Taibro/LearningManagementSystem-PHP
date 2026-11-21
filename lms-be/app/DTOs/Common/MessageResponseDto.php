<?php

namespace App\DTOs\Common;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'MessageResponseDto',
    title: 'Message Response',
    description: 'Standard message response payload',
)]
final class MessageResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly string $message,
    ) {}

    /**
     * @return array<string, string>
     */
    public function toArray(): array
    {
        return [
            'message' => $this->message,
        ];
    }

    /**
     * @return array<string, string>
     */
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
}
