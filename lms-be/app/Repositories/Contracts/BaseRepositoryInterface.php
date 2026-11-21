<?php

namespace App\Repositories\Contracts;

use App\DTOs\Common\PagedResultDto;
use Closure;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Database\Eloquent\Model;

/**
 * @template TModel of Model
 */
interface BaseRepositoryInterface
{
    /**
     * Return a fresh query builder for all records (equivalent to IQueryable FindAll).
     *
     * @return Builder<TModel>
     */
    public function findAll(): Builder;

    /**
     * Return a query builder filtered by condition (array or Closure).
     *
     * @param  Closure(Builder<TModel>): void|array<string, mixed>  $condition
     * @return Builder<TModel>
     */
    public function findByCondition(Closure|array $condition): Builder;

    /**
     * Find the first record matching the condition.
     *
     * @param  Closure(Builder<TModel>): void|array<string, mixed>  $condition
     * @param  array<int, string>  $columns
     * @return TModel|null
     */
    public function findOneByCondition(Closure|array $condition, array $columns = ['*']): ?Model;

    /**
     * Find a collection of records matching the condition.
     *
     * @param  Closure(Builder<TModel>): void|array<string, mixed>  $condition
     * @param  array<int, string>  $columns
     * @return Collection<int, TModel>
     */
    public function findListByCondition(Closure|array $condition, array $columns = ['*']): Collection;

    /**
     * Get all records.
     *
     * @param  array<int, string>  $columns
     * @return Collection<int, TModel>
     */
    public function all(array $columns = ['*']): Collection;

    /**
     * Paginate records using Laravel's native LengthAwarePaginator.
     *
     * @param  array<string, mixed>  $filters
     * @return LengthAwarePaginator<int, TModel>
     */
    public function paginate(array $filters = [], int $perPage = 15): LengthAwarePaginator;

    /**
     * Return a standardized PagedResultDto from an optional custom Builder.
     *
     * @param  Builder<TModel>|null  $query
     * @return PagedResultDto<TModel>
     */
    public function getPaged(?Builder $query = null, int $pageNumber = 1, int $pageSize = 15): PagedResultDto;

    /**
     * Find a record by primary key ID.
     *
     * @param  array<int, string>  $columns
     * @return TModel|null
     */
    public function findById(int|string $id, array $columns = ['*']): ?Model;

    /**
     * Create a new record.
     *
     * @param  array<string, mixed>  $data
     * @return TModel
     */
    public function create(array $data): Model;

    /**
     * Insert multiple records in chunks.
     *
     * @param  array<int, array<string, mixed>>  $records
     */
    public function batchCreate(array $records, int $chunkSize = 500): bool;

    /**
     * Update an existing record.
     *
     * @param  TModel  $model
     * @param  array<string, mixed>  $data
     * @return TModel
     */
    public function update(Model $model, array $data): Model;

    /**
     * Batch upsert/update multiple records using database-native conflict handling.
     *
     * @param  array<int, array<string, mixed>>  $records
     * @param  array<int, string>|string  $uniqueBy
     * @param  array<int, string>|null  $updateColumns
     */
    public function batchUpdate(array $records, array|string $uniqueBy, ?array $updateColumns = null): int;

    /**
     * Delete an existing record.
     *
     * @param  TModel  $model
     */
    public function delete(Model $model): bool;

    /**
     * Bulk delete records by primary key IDs.
     *
     * @param  array<int, int|string>  $ids
     */
    public function bulkDelete(array $ids): int;
}
