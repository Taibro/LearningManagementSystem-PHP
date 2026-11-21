<?php

namespace App\Repositories\Eloquent;

use App\DTOs\Common\PagedResultDto;
use App\Repositories\Contracts\BaseRepositoryInterface;
use Closure;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * @template TModel of Model
 *
 * @implements BaseRepositoryInterface<TModel>
 */
abstract class BaseRepository implements BaseRepositoryInterface
{
    protected ?string $connection = null;

    /**
     * @param  TModel  $model
     */
    public function __construct(
        protected Model $model
    ) {}

    /**
     * @return Builder<TModel>
     */
    protected function query(): Builder
    {
        if ($this->connection !== null) {
            /** @var Builder<TModel> $builder */
            $builder = $this->model->newModelInstance()
                ->setConnection($this->connection)
                ->newQuery();

            return $builder;
        }

        /** @var Builder<TModel> $builder */
        $builder = $this->model->newQuery();

        return $builder;
    }

    public function findAll(): Builder
    {
        return $this->query();
    }

    public function findByCondition(Closure|array $condition): Builder
    {
        return $this->query()->where($condition);
    }

    public function findOneByCondition(Closure|array $condition, array $columns = ['*']): ?Model
    {
        /** @var TModel|null $result */
        $result = $this->findByCondition($condition)->first($columns);

        return $result;
    }

    public function findListByCondition(Closure|array $condition, array $columns = ['*']): Collection
    {
        return $this->findByCondition($condition)->get($columns);
    }

    public function all(array $columns = ['*']): Collection
    {
        return $this->query()->get($columns);
    }

    public function paginate(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        $query = $this->query();

        if ($filters !== []) {
            $query->where($filters);
        }

        return $query->latest()->paginate($perPage);
    }

    public function getPaged(?Builder $query = null, int $pageNumber = 1, int $pageSize = 15): PagedResultDto
    {
        $pageNumber = max(1, $pageNumber);
        $pageSize = max(1, min($pageSize, 200));

        $builder = $query ?? $this->query();
        $totalCount = (clone $builder)->count();

        /** @var array<int, TModel> $items */
        $items = $builder
            ->forPage($pageNumber, $pageSize)
            ->get()
            ->all();

        return new PagedResultDto(
            items: $items,
            totalCount: $totalCount,
            pageNumber: $pageNumber,
            pageSize: $pageSize,
            totalPages: $totalCount > 0 ? (int) ceil($totalCount / $pageSize) : 0,
        );
    }

    public function findById(int|string $id, array $columns = ['*']): ?Model
    {
        /** @var TModel|null $result */
        $result = $this->query()->find($id, $columns);

        return $result;
    }

    public function create(array $data): Model
    {
        /** @var TModel $created */
        $created = $this->query()->create($data);

        return $created;
    }

    public function batchCreate(array $records, int $chunkSize = 500): bool
    {
        if ($records === []) {
            return true;
        }

        $now = now();
        $usesTimestamps = $this->model->usesTimestamps();
        $createdAtCol = $this->model->getCreatedAtColumn();
        $updatedAtCol = $this->model->getUpdatedAtColumn();

        $prepared = array_map(static function (array $row) use ($usesTimestamps, $createdAtCol, $updatedAtCol, $now): array {
            if ($usesTimestamps) {
                if ($createdAtCol && ! array_key_exists($createdAtCol, $row)) {
                    $row[$createdAtCol] = $now;
                }
                if ($updatedAtCol && ! array_key_exists($updatedAtCol, $row)) {
                    $row[$updatedAtCol] = $now;
                }
            }

            return $row;
        }, $records);

        foreach (array_chunk($prepared, max(1, $chunkSize)) as $chunk) {
            $this->query()->insert($chunk);
        }

        return true;
    }

    public function update(Model $model, array $data): Model
    {
        if ($this->connection !== null) {
            $model->setConnection($this->connection);
        }

        $model->update($data);

        /** @var TModel $fresh */
        $fresh = $model->fresh() ?? $model;

        return $fresh;
    }

    public function batchUpdate(array $records, array|string $uniqueBy, ?array $updateColumns = null): int
    {
        if ($records === []) {
            return 0;
        }

        return $this->query()->upsert($records, $uniqueBy, $updateColumns);
    }

    public function delete(Model $model): bool
    {
        if ($this->connection !== null) {
            $model->setConnection($this->connection);
        }

        return (bool) $model->delete();
    }

    public function bulkDelete(array $ids): int
    {
        if ($ids === []) {
            return 0;
        }

        return (int) $this->query()->whereKey($ids)->delete();
    }

    /**
     * @return TModel
     */
    public function getModel(): Model
    {
        return $this->model;
    }
}
