<?php

namespace App\Http\Controllers\Student;

use App\DTOs\Common\ErrorResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\DTOs\Student\StudentProfileResponseDto;
use App\DTOs\Student\UpdateStudentProfileRequestDto;
use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\Student\StudentProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Student Profile', description: 'API endpoints for authenticated student profile and contact declaration')]
class StudentProfileController extends Controller
{
    private const STUDENT_PREFIX = self::API_PREFIX . '/student';

    public function __construct(
        private readonly StudentProfileService $studentProfileService,
    ) {}

    /**
     * GET /api/{version}/student/profile
     */
    #[OA\Get(
        path: self::STUDENT_PREFIX . '/profile',
        operationId: 'getStudentProfile',
        tags: ['Student Profile'],
        summary: 'Get authenticated student profile',
        description: 'Retrieve the full academic and personal profile of the currently authenticated student',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        security: [['bearerAuth' => []]],
        responses: [
            new OA\Response(
                response: 200,
                description: 'Student profile retrieved successfully',
                content: new OA\JsonContent(ref: StudentProfileResponseDto::class)
            ),
            new OA\Response(
                response: 401,
                description: 'Unauthenticated',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 403,
                description: 'Forbidden (requires STUDENT role)',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 404,
                description: 'Student profile not found',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
        ]
    )]
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        return response()->json($this->studentProfileService->getProfile($user));
    }

    /**
     * PUT /api/{version}/student/profile
     */
    #[OA\Put(
        path: self::STUDENT_PREFIX . '/profile',
        operationId: 'updateStudentProfile',
        tags: ['Student Profile'],
        summary: 'Update authenticated student personal contact information',
        description: 'Update editable personal contact fields (email, phone, gender, address) for the authenticated student',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        security: [['bearerAuth' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(ref: UpdateStudentProfileRequestDto::class)
        ),
        responses: [
            new OA\Response(
                response: 200,
                description: 'Student profile updated successfully',
                content: new OA\JsonContent(ref: StudentProfileResponseDto::class)
            ),
            new OA\Response(
                response: 401,
                description: 'Unauthenticated',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 403,
                description: 'Forbidden (requires STUDENT role)',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 404,
                description: 'Student profile not found',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
            new OA\Response(
                response: 422,
                description: 'Validation error or duplicate email within school',
                content: new OA\JsonContent(ref: ErrorResponseDto::class)
            ),
        ]
    )]
    public function update(Request $request): JsonResponse
    {
        $user = $request->user();
        if (! $user instanceof User) {
            return response()->json(new MessageResponseDto('Unauthenticated.'), 401);
        }

        $dto = UpdateStudentProfileRequestDto::fromRequest($request);

        return response()->json($this->studentProfileService->updateProfile($user, $dto));
    }
}
