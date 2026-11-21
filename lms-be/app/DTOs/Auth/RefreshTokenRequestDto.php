<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'RefreshTokenRequestDto',
    title: 'Refresh Token Request',
    description: 'Payload to exchange a refresh token for a new access token',
    required: ['refreshToken'],
)]
final class RefreshTokenRequestDto
{
    public function __construct(
        #[OA\Property]
        public readonly string $refreshToken,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'refreshToken' => ['required', 'string'],
        ]);

        return new self(refreshToken: $validated['refreshToken']);
    }
}
