<?php

namespace App\Models;

use Carbon\Carbon;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;

/**
 * Class ImageUpload
 *
 * @property int $id
 * @property string $image_uploads_id
 * @property int $school_id
 * @property int|null $uploaded_by
 * @property string $disk
 * @property string $bucket
 * @property string $object_key
 * @property string $original_name
 * @property string $mime_type
 * @property int $file_size
 * @property string $category
 * @property string $visibility
 * @property string $status
 * @property string|null $etag
 * @property Carbon|null $expires_at
 * @property Carbon|null $uploaded_at
 * @property int|null $created_by
 * @property int|null $updated_by
 * @property Carbon $created_at
 * @property Carbon $updated_at
 * @property School $school
 * @property User|null $uploader
 */
class ImageUpload extends Model
{
    public const CATEGORY_AVATAR = 'AVATAR';

    public const CATEGORY_SCHOOL_LOGO = 'SCHOOL_LOGO';

    public const CATEGORY_CLASS_MATERIAL = 'CLASS_MATERIAL';

    public const CATEGORY_TEACHER_EVIDENCE = 'TEACHER_EVIDENCE';

    public const CATEGORY_GENERAL = 'GENERAL';

    public const VISIBILITY_PRIVATE = 'PRIVATE';

    public const VISIBILITY_PUBLIC = 'PUBLIC';

    public const STATUS_PENDING = 'PENDING';

    public const STATUS_UPLOADED = 'UPLOADED';

    public const STATUS_FAILED = 'FAILED';

    public const STATUS_DELETED = 'DELETED';

    /** @var array<int, string> */
    public const CATEGORIES = [
        self::CATEGORY_AVATAR,
        self::CATEGORY_SCHOOL_LOGO,
        self::CATEGORY_CLASS_MATERIAL,
        self::CATEGORY_TEACHER_EVIDENCE,
        self::CATEGORY_GENERAL,
    ];

    /** @var array<int, string> */
    public const VISIBILITIES = [
        self::VISIBILITY_PRIVATE,
        self::VISIBILITY_PUBLIC,
    ];

    protected $table = 'image_uploads';

    protected $casts = [
        'image_uploads_id' => 'string',
        'school_id' => 'int',
        'uploaded_by' => 'int',
        'file_size' => 'int',
        'expires_at' => 'datetime',
        'uploaded_at' => 'datetime',
        'created_by' => 'int',
        'updated_by' => 'int',
    ];

    protected $fillable = [
        'image_uploads_id',
        'school_id',
        'uploaded_by',
        'disk',
        'bucket',
        'object_key',
        'original_name',
        'mime_type',
        'file_size',
        'category',
        'visibility',
        'status',
        'etag',
        'expires_at',
        'uploaded_at',
        'created_by',
        'updated_by',
    ];

    protected static function booted(): void
    {
        static::creating(static function (self $model): void {
            if (empty($model->getAttribute('image_uploads_id'))) {
                $model->image_uploads_id = Str::uuid()->toString();
            }
        });
    }

    /**
     * @return BelongsTo<School, $this>
     */
    public function school(): BelongsTo
    {
        return $this->belongsTo(School::class, 'school_id');
    }

    /**
     * @return BelongsTo<User, $this>
     */
    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }

    public function resolvePublicUrl(): ?string
    {
        if ($this->visibility !== self::VISIBILITY_PUBLIC) {
            return null;
        }

        $baseUrl = rtrim((string) config("filesystems.disks.{$this->disk}.url", ''), '/');
        if ($baseUrl === '') {
            return null;
        }

        return $baseUrl . '/' . ltrim((string) $this->object_key, '/');
    }
}
