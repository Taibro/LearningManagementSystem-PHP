<?php

namespace App\DTOs\Auth;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'UserProfileResponseDto',
    title: 'User Profile Response',
    description: 'Current authenticated user profile payload',
)]
final class UserProfileResponseDto implements JsonSerializable
{
    /**
     * @param  array<int, string>  $roles
     */
    public function __construct(
        #[OA\Property]
        public readonly int $id,

        #[OA\Property]
        public readonly int $userId,

        #[OA\Property(nullable: true)]
        public readonly ?string $usersId,

        #[OA\Property(nullable: true)]
        public readonly ?string $keycloakId,

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

        #[OA\Property(nullable: true)]
        public readonly ?string $schoolName,

        #[OA\Property(nullable: true)]
        public readonly ?string $studentCode,

        #[OA\Property(nullable: true)]
        public readonly ?string $teacherCode,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'userId' => $this->userId,
            'usersId' => $this->usersId,
            'keycloakId' => $this->keycloakId,
            'fullName' => $this->fullName,
            'email' => $this->email,
            'phone' => $this->phone,
            'avatarUrl' => $this->avatarUrl,
            'role' => $this->role,
            'roles' => $this->roles,
            'schoolId' => $this->schoolId,
            'schoolCode' => $this->schoolCode,
            'schoolName' => $this->schoolName,
            'studentCode' => $this->studentCode,
            'teacherCode' => $this->teacherCode,
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
