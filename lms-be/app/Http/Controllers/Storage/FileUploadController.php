<?php

namespace App\Http\Controllers\Storage;

use App\DTOs\Common\ErrorResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\DTOs\Storage\CreatePresignedUploadRequestDto;
use App\DTOs\Storage\PresignedDownloadRequestDto;
use App\DTOs\Storage\PresignedDownloadResponseDto;
use App\DTOs\Storage\PresignedUploadResponseDto;
use App\DTOs\Storage\UploadFileResponseDto;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Contracts\FileStorageServiceInterface;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'File Uploads', description: 'Cloudflare R2 presigned upload and download URL endpoints')]
class FileUploadController extends Controller
{
    private const UPLOADS_PREFIX = self::API_PREFIX . '/uploads';

    public function __construct(
        private readonly FileStorageServiceInterface $fileStorageService,
    ) {}

    /**
     * POST /api/{version}/uploads/presign
     */
    #[OA\Post(
        path: self::UPLOADS_PREFIX . '/presign',
        operationId: 'createPresignedUploadUrl',
        tags: ['File Uploads'],
        summary: 'Generate a temporary presigned PUT URL for uploading a file directly to Cloudflare R2',
        parameters: [
            new OA\Parameter(name: 'version', in: 'path', required: true, description: 'API version', schema: new OA\Schema(type: 'string', default: 'v1')),
        ],
        security: [['bearerAuth' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(ref: CreatePresignedUploadRequestDto::class)
        ),
        responses: [
            new OA\Response(response: 201, description: 'Presigned upload URL generated', content: new OA\JsonContent(ref: PresignedUploadResponseDto::class)),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 422, description: 'Validation error', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
        ]
    )]
    public function presignUpload(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        $dto = CreatePresignedUploadRequestDto::fromRequest($request);

        return response()->json(
            $this->fileStorageService->createPresignedUpload($user, $dto),
            201
        );
    }

    /**
     * POST /api/{version}/uploads/{id}/confirm
     */
    #[OA\Post(
        path: self::UPLOADS_PREFIX . '/{id}/confirm',
        operationId: 'confirmPresignedUpload',
        tags: ['File Uploads'],
        summary: 'Confirm a direct R2 upload, verify magic bytes, and mark the image_uploads record as UPLOADED',
        parameters: [
            new OA\Parameter(name: 'version', in: 'path', required: true, description: 'API version', schema: new OA\Schema(type: 'string', default: 'v1')),
            new OA\Parameter(name: 'id', in: 'path', required: true, description: 'ImageUpload record ID', schema: new OA\Schema(type: 'integer')),
        ],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 200, description: 'Upload confirmed', content: new OA\JsonContent(ref: UploadFileResponseDto::class)),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 403, description: 'Forbidden', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 404, description: 'Upload record not found', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 409, description: 'Object not yet uploaded to R2', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 422, description: 'Invalid file magic bytes', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
        ]
    )]
    public function confirm(Request $request, string $version, int $id): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        return response()->json(
            $this->fileStorageService->confirmUpload($user, $id)
        );
    }

    /**
     * GET /api/{version}/uploads/{id}/download-url
     */
    #[OA\Get(
        path: self::UPLOADS_PREFIX . '/{id}/download-url',
        operationId: 'getPresignedDownloadUrl',
        tags: ['File Uploads'],
        summary: 'Generate a temporary presigned GET URL to view or download a confirmed file from Cloudflare R2',
        parameters: [
            new OA\Parameter(name: 'version', in: 'path', required: true, description: 'API version', schema: new OA\Schema(type: 'string', default: 'v1')),
            new OA\Parameter(name: 'id', in: 'path', required: true, description: 'ImageUpload record ID', schema: new OA\Schema(type: 'integer')),
            new OA\Parameter(name: 'disposition', in: 'query', required: false, description: 'inline or attachment', schema: new OA\Schema(type: 'string', default: 'inline')),
        ],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 200, description: 'Presigned download URL generated', content: new OA\JsonContent(ref: PresignedDownloadResponseDto::class)),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 404, description: 'Upload record not found', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 409, description: 'File is not yet confirmed as UPLOADED', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
        ]
    )]
    public function presignDownload(Request $request, string $version, int $id): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        $dto = PresignedDownloadRequestDto::fromRequest($request);

        return response()->json(
            $this->fileStorageService->createPresignedDownload($user, $id, $dto)
        );
    }

    /**
     * DELETE /api/{version}/uploads/{id}
     */
    #[OA\Delete(
        path: self::UPLOADS_PREFIX . '/{id}',
        operationId: 'deleteUploadedFile',
        tags: ['File Uploads'],
        summary: 'Delete a file from Cloudflare R2 and remove its image_uploads record',
        parameters: [
            new OA\Parameter(name: 'version', in: 'path', required: true, description: 'API version', schema: new OA\Schema(type: 'string', default: 'v1')),
            new OA\Parameter(name: 'id', in: 'path', required: true, description: 'ImageUpload record ID', schema: new OA\Schema(type: 'integer')),
        ],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(response: 200, description: 'File deleted', content: new OA\JsonContent(ref: MessageResponseDto::class)),
            new OA\Response(response: 401, description: 'Unauthenticated', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 403, description: 'Forbidden', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
            new OA\Response(response: 404, description: 'Upload record not found', content: new OA\JsonContent(ref: ErrorResponseDto::class)),
        ]
    )]
    public function destroy(Request $request, string $version, int $id): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        $this->fileStorageService->deleteUpload($user, $id);

        return response()->json(new MessageResponseDto('Đã xóa tệp thành công.'));
    }
}
