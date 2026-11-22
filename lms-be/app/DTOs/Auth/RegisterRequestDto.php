<?php

namespace App\DTOs\Auth;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'RegisterRequestDto',
    title: 'Register Request',
    description: 'Payload to register a new user in Keycloak and PostgreSQL',
    required: ['fullName', 'email', 'password'],
)]
final class RegisterRequestDto
{
    public function __construct(
        #[OA\Property]
        public readonly string $fullName,

        #[OA\Property]
        public readonly string $email,

        #[OA\Property]
        public readonly string $password,

        #[OA\Property(description: 'School code (e.g. HUIT, HCMUT). Optional for SAAS_ADMIN', nullable: true)]
        public readonly ?string $school = null,

        #[OA\Property(description: 'Primary user code / Keycloak username', nullable: true)]
        public readonly ?string $userCode = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $loginCode = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $studentCode = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $teacherCode = null,

        #[OA\Property(description: 'STUDENT | LECTURER | SCHOOL_ADMIN | DEAN_OF_FACULTY | DEAN_OF_DEPARTMENT | SAAS_ADMIN', nullable: true)]
        public readonly ?string $userType = 'STUDENT',

        #[OA\Property(nullable: true)]
        public readonly ?string $phone = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $major = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $degreeLevel = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $trainingType = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $className = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $specialization = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $qualification = null,

        #[OA\Property(nullable: true)]
        public readonly ?int $departmentId = null,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'fullName' => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'max:255'],
            'password' => ['required', 'string', 'min:6'],
            'userCode' => ['nullable', 'string', 'max:50'],
            'loginCode' => ['nullable', 'string', 'max:50'],
            'studentCode' => ['nullable', 'string', 'max:50'],
            'teacherCode' => ['nullable', 'string', 'max:50'],
            'userType' => ['nullable', 'string'],
            'school' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'major' => ['nullable', 'string', 'max:100'],
            'degreeLevel' => ['nullable', 'string', 'max:50'],
            'trainingType' => ['nullable', 'string', 'max:50'],
            'className' => ['nullable', 'string', 'max:50'],
            'specialization' => ['nullable', 'string', 'max:255'],
            'qualification' => ['nullable', 'string', 'max:255'],
            'departmentId' => ['nullable', 'integer'],
        ]);

        return new self(
            fullName: $validated['fullName'],
            email: $validated['email'],
            password: $validated['password'],
            school: $validated['school'] ?? null,
            userCode: $validated['userCode'] ?? null,
            loginCode: $validated['loginCode'] ?? null,
            studentCode: $validated['studentCode'] ?? null,
            teacherCode: $validated['teacherCode'] ?? null,
            userType: $validated['userType'] ?? 'STUDENT',
            phone: $validated['phone'] ?? null,
            major: $validated['major'] ?? null,
            degreeLevel: $validated['degreeLevel'] ?? null,
            trainingType: $validated['trainingType'] ?? null,
            className: $validated['className'] ?? null,
            specialization: $validated['specialization'] ?? null,
            qualification: $validated['qualification'] ?? null,
            departmentId: isset($validated['departmentId']) ? (int) $validated['departmentId'] : null,
        );
    }

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return array_filter([
            'fullName' => $this->fullName,
            'email' => $this->email,
            'password' => $this->password,
            'school' => $this->school,
            'userCode' => $this->userCode,
            'loginCode' => $this->loginCode,
            'studentCode' => $this->studentCode,
            'teacherCode' => $this->teacherCode,
            'userType' => $this->userType,
            'phone' => $this->phone,
            'major' => $this->major,
            'degreeLevel' => $this->degreeLevel,
            'trainingType' => $this->trainingType,
            'className' => $this->className,
            'specialization' => $this->specialization,
            'qualification' => $this->qualification,
            'departmentId' => $this->departmentId,
        ], static fn ($value) => $value !== null);
    }
}
