<?php

namespace App\Repositories\Eloquent;

use App\Models\School;
use App\Repositories\Contracts\SchoolRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

/**
 * @extends BaseRepository<School>
 */
class SchoolRepository extends BaseRepository implements SchoolRepositoryInterface
{
    protected ?string $connection = 'pgsql_owner';

    public function __construct(School $model)
    {
        parent::__construct($model);
    }

    public function findByCode(string $code): ?School
    {
        return $this->query()
            ->whereRaw('UPPER(code) = ?', [strtoupper(trim($code))])
            ->first();
    }

    public function findFirstOrderedById(): ?School
    {
        return $this->query()
            ->orderBy('id')
            ->first();
    }

    public function getActiveSchools(): Collection
    {
        return $this->query()
            ->where('is_active', true)
            ->orderBy('id')
            ->get(['id', 'code', 'name']);
    }
}
