<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'RefreshTokenRequestDto',
    title: 'Refresh Token Request',
    description: 'Payload to exchange a refresh token for a new access token',
)]
final class RefreshTokenRequestDto
{
    public function __construct(
        #[OA\Property(description: 'Refresh token (optional when sent via HttpOnly cookie)', nullable: true)]
        public readonly string $refreshToken,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $cookieName = (string) config('keycloak.cookie.refresh_name', 'lms_refresh_token');
        $fallbackCookie = $request->cookie($cookieName);

        if (! $request->filled('refreshToken') && is_string($fallbackCookie) && trim($fallbackCookie) !== '') {
            $request->merge(['refreshToken' => trim($fallbackCookie)]);
        }

        $validated = $request->validate([
            'refreshToken' => ['required', 'string'],
        ]);

        return new self(refreshToken: (string) $validated['refreshToken']);
    }
}
