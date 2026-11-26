<?php

namespace App\DTOs\Student;

use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'UpdateStudentProfileRequestDto',
    title: 'Update Student Profile Request',
    description: 'Editable personal contact fields for authenticated student',
    required: ['email', 'phone'],
)]
final class UpdateStudentProfileRequestDto
{
    public function __construct(
        #[OA\Property]
        public readonly string $email,

        #[OA\Property]
        public readonly string $phone,

        #[OA\Property(nullable: true)]
        public readonly ?string $gender = null,

        #[OA\Property(nullable: true)]
        public readonly ?string $address = null,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $validated = $request->validate([
            'email' => ['required', 'email', 'max:255'],
            'phone' => ['required', 'string', 'max:20'],
            'gender' => ['nullable', 'string', 'in:MALE,FEMALE,OTHER'],
            'address' => ['nullable', 'string', 'max:500'],
        ]);

        $rawGender = isset($validated['gender']) ? trim((string) $validated['gender']) : '';
        $rawAddress = isset($validated['address']) ? trim((string) $validated['address']) : '';

        return new self(
            email: strtolower(trim((string) $validated['email'])),
            phone: trim((string) $validated['phone']),
            gender: $rawGender !== '' ? strtoupper($rawGender) : null,
            address: $rawAddress !== '' ? $rawAddress : null,
        );
    }
}
