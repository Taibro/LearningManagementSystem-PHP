<?php

namespace App\DTOs\Auth;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'AuthTokenResponseDto',
    title: 'Auth Token Response',
    description: 'Authentication response containing JWT tokens and authenticated user profile',
)]
final class AuthTokenResponseDto implements JsonSerializable
{
    /**
     * @param  array<int, string>  $roles
     */
    public function __construct(
        #[OA\Property(nullable: true)]
        public readonly ?string $token,

        #[OA\Property(nullable: true)]
        public readonly ?string $accessToken,

        #[OA\Property(nullable: true)]
        public readonly ?string $refreshToken,

        #[OA\Property(nullable: true)]
        public readonly ?int $expiresIn,

        #[OA\Property]
        public readonly int $id,

        #[OA\Property]
        public readonly int $userId,

        #[OA\Property(nullable: true)]
        public readonly ?string $usersId,

        #[OA\Property(nullable: true)]
        public readonly ?string $keycloakId,

        #[OA\Property]
        public readonly string $userCode,

        #[OA\Property(nullable: true)]
        public readonly ?string $studentCode,

        #[OA\Property(nullable: true)]
        public readonly ?string $teacherCode,

        #[OA\Property]
        public readonly string $fullName,

        #[OA\Property]
        public readonly string $email,

        #[OA\Property(nullable: true)]
        public readonly ?string $phone,

        #[OA\Property(nullable: true)]
        public readonly ?string $avatarUrl,

        #[OA\Property]
        public readonly string $role,

        #[OA\Property(type: 'array', items: new OA\Items(type: 'string'))]
        public readonly array $roles,

        #[OA\Property]
        public readonly int $schoolId,

        #[OA\Property(nullable: true)]
        public readonly ?string $schoolCode,

        #[OA\Property]
        public readonly string $schoolName,

        #[OA\Property]
        public readonly bool $require2fa = false,

        #[OA\Property]
        public readonly bool $requireSetup = false,
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
            'id' => $this->id,
            'userId' => $this->userId,
            'usersId' => $this->usersId,
            'keycloakId' => $this->keycloakId,
            'userCode' => $this->userCode,
            'studentCode' => $this->studentCode,
            'teacherCode' => $this->teacherCode,
            'fullName' => $this->fullName,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatarUrl' => $this->avatarUrl,
            'role' => $this->role,
            'roles' => $this->roles,
            'schoolId' => $this->schoolId,
            'schoolCode' => $this->schoolCode,
            'schoolName' => $this->schoolName,
            'require2fa' => $this->require2fa,
            'requireSetup' => $this->requireSetup,
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
