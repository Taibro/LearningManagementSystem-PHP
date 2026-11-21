<?php

namespace App\Repositories\Contracts;

use App\Models\School;
use Illuminate\Database\Eloquent\Collection;

/**
 * @extends BaseRepositoryInterface<School>
 */
interface SchoolRepositoryInterface extends BaseRepositoryInterface
{
    public function findByCode(string $code): ?School;

    public function findFirstOrderedById(): ?School;

    /**
     * @return Collection<int, School>
     */
    public function getActiveSchools(): Collection;
}
