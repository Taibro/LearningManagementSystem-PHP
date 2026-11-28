<?php

namespace App\Repositories\Eloquent;

use App\Models\ImageUpload;
use App\Repositories\Contracts\ImageUploadRepositoryInterface;

/**
 * @extends BaseRepository<ImageUpload>
 */
class ImageUploadRepository extends BaseRepository implements ImageUploadRepositoryInterface
{
    protected ?string $connection = null;

    public function __construct(ImageUpload $model)
    {
        parent::__construct($model);
    }

    public function findByIdForSchool(int $id, int $schoolId): ?ImageUpload
    {
        /** @var ImageUpload|null $upload */
        $upload = $this->query()
            ->where('id', $id)
            ->where('school_id', $schoolId)
            ->first();

        return $upload;
    }

    public function findByPublicUuidForSchool(string $uploadUuid, int $schoolId): ?ImageUpload
    {
        /** @var ImageUpload|null $upload */
        $upload = $this->query()
            ->where('image_uploads_id', $uploadUuid)
            ->where('school_id', $schoolId)
            ->first();

        return $upload;
    }

    public function findByObjectKey(string $objectKey): ?ImageUpload
    {
        /** @var ImageUpload|null $upload */
        $upload = $this->query()
            ->where('object_key', $objectKey)
            ->first();

        return $upload;
    }
}
