<?php

namespace App\DTOs\Storage;

use App\Models\ImageUpload;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use OpenApi\Attributes as OA;

#[OA\Schema(
    schema: 'CreatePresignedUploadRequestDto',
    title: 'Create Presigned Upload Request',
    description: 'Metadata payload used to generate a temporary Cloudflare R2 PUT presigned URL',
    required: ['category', 'fileName', 'mimeType', 'fileSize'],
)]
final class CreatePresignedUploadRequestDto
{
    public function __construct(
        #[OA\Property(description: 'Upload category: AVATAR | SCHOOL_LOGO | CLASS_MATERIAL | TEACHER_EVIDENCE | GENERAL')]
        public readonly string $category,

        #[OA\Property(description: 'Original client file name including extension')]
        public readonly string $fileName,

        #[OA\Property(description: 'MIME type of the file to be uploaded')]
        public readonly string $mimeType,

        #[OA\Property(description: 'File size in bytes')]
        public readonly int $fileSize,

        #[OA\Property(description: 'Access visibility: PRIVATE | PUBLIC', nullable: true)]
        public readonly string $visibility = ImageUpload::VISIBILITY_PRIVATE,
    ) {}

    public static function fromRequest(Request $request): self
    {
        $maxUploadBytes = max(1, (int) config('filesystems.presigned.max_upload_size_mb', 20)) * 1024 * 1024;

        $validated = $request->validate([
            'category' => ['required', 'string', Rule::in(ImageUpload::CATEGORIES)],
            'fileName' => ['required', 'string', 'max:255'],
            'mimeType' => ['required', 'string', 'max:150'],
            'fileSize' => ['required', 'integer', 'min:1', 'max:' . $maxUploadBytes],
            'visibility' => ['nullable', 'string', Rule::in(ImageUpload::VISIBILITIES)],
        ]);

        return new self(
            category: strtoupper(trim((string) $validated['category'])),
            fileName: trim((string) $validated['fileName']),
            mimeType: strtolower(trim((string) $validated['mimeType'])),
            fileSize: (int) $validated['fileSize'],
            visibility: isset($validated['visibility'])
                ? strtoupper(trim((string) $validated['visibility']))
                : ImageUpload::VISIBILITY_PRIVATE,
        );
    }
}
