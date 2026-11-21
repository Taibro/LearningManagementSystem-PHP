<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'VerifyLogin2faRequestDto',
    title: 'Verify Login 2FA Request',
    description: 'Payload to complete 2FA verification during login',
)]
final class VerifyLogin2faRequestDto
{
    public function __construct(
        #[OA\Property(nullable: true)]
        public readonly ?string $email = null,

        #[OA\Property(description: '6-digit TOTP code', nullable: true)]
        public readonly ?string $code = null,
    ) {}

    public static function fromRequest(Request $request): self
    {
        return new self(
            email: $request->input('email') ? (string) $request->input('email') : null,
            code: $request->input('code') ? (string) $request->input('code') : null,
        );
    }
}
