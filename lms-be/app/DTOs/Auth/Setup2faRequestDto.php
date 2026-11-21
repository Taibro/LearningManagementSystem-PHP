<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'Setup2faRequestDto',
    title: 'Setup 2FA Request',
    description: 'Payload to request a TOTP QR code setup URI',
)]
final class Setup2faRequestDto
{
    public function __construct(
        #[OA\Property(nullable: true)]
        public readonly string $email = 'admin@edusaas.io',
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'email' => ['nullable', 'email', 'max:255'],
        ]);

        return new self(email: (string) ($validated['email'] ?? 'admin@edusaas.io'));
    }
}
