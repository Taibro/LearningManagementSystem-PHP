<?php

namespace App\DTOs\Auth;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'RefreshTokenResponseDto',
    title: 'Refresh Token Response',
    description: 'Response payload containing refreshed access and refresh tokens',
)]
final class RefreshTokenResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly string $token,

        #[OA\Property]
        public readonly string $accessToken,

        #[OA\Property]
        public readonly string $refreshToken,

        #[OA\Property]
        public readonly int $expiresIn,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'token' => $this->token,
            'accessToken' => $this->accessToken,
            'refreshToken' => $this->refreshToken,
            'expiresIn' => $this->expiresIn,
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
