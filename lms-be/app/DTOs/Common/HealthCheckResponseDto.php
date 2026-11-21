<?php

namespace App\DTOs\Common;

use JsonSerializable;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'HealthCheckResponseDto',
    title: 'Health Check Response',
    description: 'Service health status report for application dependencies',
)]
final class HealthCheckResponseDto implements JsonSerializable
{
    /**
     * @param  array<string, string>  $checks
     */
    public function __construct(
        #[OA\Property]
        public readonly string $status,

        #[OA\Property]
        public readonly string $timestamp,

        #[OA\Property(
            type: 'object',
            additionalProperties: new OA\AdditionalProperties(type: 'string')
        )]
        public readonly array $checks,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'status' => $this->status,
            'timestamp' => $this->timestamp,
            'checks' => $this->checks,
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
