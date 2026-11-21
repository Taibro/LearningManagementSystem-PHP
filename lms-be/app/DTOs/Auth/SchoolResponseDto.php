<?php

namespace App\DTOs\Auth;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'SchoolResponseDto',
    title: 'School Response',
    description: 'Active school item for tenant dropdown',
)]
final class SchoolResponseDto implements JsonSerializable
{
    public function __construct(
        #[OA\Property]
        public readonly int $id,

        #[OA\Property]
        public readonly string $value,

        #[OA\Property]
        public readonly string $code,

        #[OA\Property]
        public readonly string $label,

        #[OA\Property]
        public readonly string $name,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'value' => $this->value,
            'code' => $this->code,
            'label' => $this->label,
            'name' => $this->name,
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
