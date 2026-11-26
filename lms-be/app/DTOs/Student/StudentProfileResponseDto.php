<?php

namespace App\DTOs\Student;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'StudentProfileResponseDto',
    title: 'Student Profile Response',
    description: 'Detailed student profile payload for Student Portal',
)]
final class StudentProfileResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly int $id,

        #[OA\Property]
        public readonly string $studentCode,

        #[OA\Property]
        public readonly string $fullName,

        #[OA\Property(nullable: true)]
        public readonly ?string $gender,

        #[OA\Property(nullable: true)]
        public readonly ?string $dateOfBirth,

        #[OA\Property(nullable: true)]
        public readonly ?string $citizenIdNumber,

        #[OA\Property]
        public readonly string $email,

        #[OA\Property(nullable: true)]
        public readonly ?string $phone,

        #[OA\Property(nullable: true)]
        public readonly ?string $address,

        #[OA\Property(nullable: true)]
        public readonly ?string $avatarUrl,

        #[OA\Property(nullable: true)]
        public readonly ?string $className,

        #[OA\Property(nullable: true)]
        public readonly ?string $major,

        #[OA\Property(nullable: true)]
        public readonly ?string $degreeLevel,

        #[OA\Property(nullable: true)]
        public readonly ?string $trainingType,

        #[OA\Property(nullable: true)]
        public readonly ?int $departmentId,

        #[OA\Property(nullable: true)]
        public readonly ?string $departmentName,

        #[OA\Property(nullable: true)]
        public readonly ?int $enrollmentYear,

        #[OA\Property]
        public readonly string $enrollmentStatus,

        #[OA\Property(nullable: true)]
        public readonly ?string $schoolName,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'studentCode' => $this->studentCode,
            'fullName' => $this->fullName,
            'gender' => $this->gender,
            'dateOfBirth' => $this->dateOfBirth,
            'citizenIdNumber' => $this->citizenIdNumber,
            'email' => $this->email,
            'phone' => $this->phone,
            'address' => $this->address,
            'avatarUrl' => $this->avatarUrl,
            'className' => $this->className,
            'major' => $this->major,
            'degreeLevel' => $this->degreeLevel,
            'trainingType' => $this->trainingType,
            'departmentId' => $this->departmentId,
            'departmentName' => $this->departmentName,
            'enrollmentYear' => $this->enrollmentYear,
            'enrollmentStatus' => $this->enrollmentStatus,
            'schoolName' => $this->schoolName,
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
