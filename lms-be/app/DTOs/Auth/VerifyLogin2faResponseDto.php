<?php

namespace App\DTOs\Auth;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'VerifyLogin2faResponseDto',
    title: 'Verify Login 2FA Response',
    description: 'Authenticated user session after 2FA verification',
)]
final class VerifyLogin2faResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property(nullable: true)]
        public readonly ?string $token,

        #[OA\Property(nullable: true)]
        public readonly ?int $id,

        #[OA\Property]
        public readonly string $fullName,

        #[OA\Property(nullable: true)]
        public readonly ?string $email,

        #[OA\Property]
        public readonly int $schoolId,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'token' => $this->token,
            'id' => $this->id,
            'fullName' => $this->fullName,
            'email' => $this->email,
            'schoolId' => $this->schoolId,
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
