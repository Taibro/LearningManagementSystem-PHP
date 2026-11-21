<?php

namespace App\DTOs\Auth;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'Setup2faResponseDto',
    title: 'Setup 2FA Response',
    description: 'QR code image URI for TOTP setup',
)]
final class Setup2faResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly string $qrCodeImageUri,
    ) {}

    /**
     * @return array<string, string>
     */
    public function toArray(): array
    {
        return [
            'qrCodeImageUri' => $this->qrCodeImageUri,
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
