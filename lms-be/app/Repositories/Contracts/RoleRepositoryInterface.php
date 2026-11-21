<?php

namespace App\Repositories\Contracts;

use App\Models\Role;

/**
 * @extends BaseRepositoryInterface<Role>
 */
interface RoleRepositoryInterface extends BaseRepositoryInterface
{
    public function findByName(string $name): ?Role;
}
