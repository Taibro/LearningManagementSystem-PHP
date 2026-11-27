<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'LogoutRequestDto',
    title: 'Logout Request',
    description: 'Payload to revoke Keycloak session',
)]
final class LogoutRequestDto
{
    public function __construct(
        #[OA\Property(nullable: true)]
        public readonly ?string $refreshToken = null,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'refreshToken' => ['nullable', 'string'],
        ]);

        $cookieName = (string) config('keycloak.cookie.refresh_name', 'lms_refresh_token');
        $cookieRefresh = $request->cookie($cookieName);
        $resolved = $validated['refreshToken']
            ?? (is_string($cookieRefresh) && trim($cookieRefresh) !== '' ? trim($cookieRefresh) : null);

        return new self(refreshToken: $resolved);
    }
}
