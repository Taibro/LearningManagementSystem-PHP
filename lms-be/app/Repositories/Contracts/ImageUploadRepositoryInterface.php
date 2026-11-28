<?php

namespace App\Repositories\Contracts;

use App\Models\ImageUpload;

/**
 * @extends BaseRepositoryInterface<ImageUpload>
 */
interface ImageUploadRepositoryInterface extends BaseRepositoryInterface
{
    public function findByIdForSchool(int $id, int $schoolId): ?ImageUpload;

    public function findByPublicUuidForSchool(string $uploadUuid, int $schoolId): ?ImageUpload;

    public function findByObjectKey(string $objectKey): ?ImageUpload;
}
