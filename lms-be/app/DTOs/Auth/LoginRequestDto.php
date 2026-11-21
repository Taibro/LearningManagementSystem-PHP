<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'LoginRequestDto',
    title: 'Login Request',
    description: 'Credentials payload for Keycloak Direct Access Grant login',
    required: ['loginCode', 'password'],
)]
final class LoginRequestDto
{
    public function __construct(
        #[OA\Property(description: 'Student code, teacher code, username, or email')]
        public readonly string $loginCode,

        #[OA\Property]
        public readonly string $password,

        #[OA\Property(description: 'STUDENT | LECTURER | SCHOOL_ADMIN | SAAS_ADMIN', nullable: true)]
        public readonly string $userType = 'STUDENT',

        #[OA\Property(description: 'School code (e.g. HUIT, HCMUT)', nullable: true)]
        public readonly ?string $school = null,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'loginCode' => ['required', 'string'],
            'password' => ['required', 'string'],
            'userType' => ['nullable', 'string'],
            'school' => ['nullable', 'string'],
        ]);

        return new self(
            loginCode: $validated['loginCode'],
            password: $validated['password'],
            userType: $validated['userType'] ?? 'STUDENT',
            school: $validated['school'] ?? null,
        );
    }
}
