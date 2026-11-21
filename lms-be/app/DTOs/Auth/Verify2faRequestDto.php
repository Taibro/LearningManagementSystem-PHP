<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'Verify2faRequestDto',
    title: 'Verify 2FA Setup Request',
    description: 'Payload to verify a 6-digit TOTP code during 2FA setup',
    required: ['code'],
)]
final class Verify2faRequestDto
{
    public function __construct(
        #[OA\Property(description: '6-digit TOTP verification code')]
        public readonly string $code,
    ) {}

    public static function fromRequest(Request $request): self
    {
        return new self(code: (string) $request->input('code', ''));
    }
}
