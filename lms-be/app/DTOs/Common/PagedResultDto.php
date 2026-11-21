<?php

namespace App\DTOs\Common;

use JsonSerializable;
use OpenApi\Attributes as OA;

/**
 * @template TItem
 */
#[OA\Schema(
    schema: 'PagedResultDto',
    title: 'Paged Result',
    description: 'Standardized paginated result envelope',
)]
final class PagedResultDto implements JsonSerializable
{
    /**
     * @param  array<int, TItem>  $items
     */
    public function __construct(
        #[OA\Property(type: 'array', items: new OA\Items())]
        public readonly array $items,

        #[OA\Property]
        public readonly int $totalCount,

        #[OA\Property]
        public readonly int $pageNumber,

        #[OA\Property]
        public readonly int $pageSize,

        #[OA\Property]
        public readonly int $totalPages,
    ) {}

    /**
     * @return array<string, mixed>
     */
    public function toArray(): array
    {
        return [
            'items' => $this->items,
            'totalCount' => $this->totalCount,
            'pageNumber' => $this->pageNumber,
            'pageSize' => $this->pageSize,
            'totalPages' => $this->totalPages,
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
