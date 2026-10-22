<?php

namespace App\Http\Controllers\Api\V1;

use App\DTOs\CourseData;
use App\Http\Controllers\Controller;
use App\Http\Requests\Course\StoreCourseRequest;
use App\Http\Requests\Course\UpdateCourseRequest;
use App\Http\Resources\CourseResource;
use App\Models\Course;
use App\Services\CourseService;
use App\Traits\ApiResponse;
use Illuminate\Http\Request;
use OpenApi\Attributes as OA;

#[OA\Tag(name: 'Courses', description: 'API endpoints for managing courses')]
class CourseController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly CourseService $courseService,
    ) {}

    #[OA\Get(
        path: '/api/v1/courses',
        operationId: 'getCoursesList',
        tags: ['Courses'],
        summary: 'Get list of courses',
        description: 'Returns a paginated list of courses with optional search and status filters',
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'status', in: 'query', required: false, description: 'Course status', schema: new OA\Schema(type: 'string', enum: ['draft', 'published', 'archived'])),
            new OA\Parameter(name: 'search', in: 'query', required: false, description: 'Search keyword', schema: new OA\Schema(type: 'string')),
            new OA\Parameter(name: 'per_page', in: 'query', required: false, description: 'Items per page', schema: new OA\Schema(type: 'integer', default: 15)),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Courses list retrieved successfully'),
            new OA\Response(response: 401, description: 'Unauthenticated'),
        ]
    )]
    public function index(Request $request)
    {
        $courses = $this->courseService->list(
            filters: $request->only(['status', 'search']),
            perPage: (int) $request->get('per_page', 15),
        );

        return CourseResource::collection($courses);
    }

    #[OA\Get(
        path: '/api/v1/courses/{course}',
        operationId: 'getCourseById',
        tags: ['Courses'],
        summary: 'Get course details by ID',
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'course', in: 'path', required: true, description: 'Course ID', schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Course details retrieved successfully'),
            new OA\Response(response: 404, description: 'Course not found'),
            new OA\Response(response: 401, description: 'Unauthenticated'),
        ]
    )]
    public function show(int $id)
    {
        return $this->success(new CourseResource($this->courseService->find($id)));
    }

    #[OA\Post(
        path: '/api/v1/courses',
        operationId: 'createCourse',
        tags: ['Courses'],
        summary: 'Create a new course',
        security: [['bearerAuth' => []]],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                required: ['title', 'description', 'instructor_id', 'price', 'duration_hours'],
                properties: [
                    new OA\Property(property: 'title', type: 'string', example: 'Lập trình Laravel'),
                    new OA\Property(property: 'description', type: 'string', example: 'Khóa học Laravel từ cơ bản đến nâng cao'),
                    new OA\Property(property: 'instructor_id', type: 'integer', example: 1),
                    new OA\Property(property: 'price', type: 'number', format: 'float', example: 499000),
                    new OA\Property(property: 'duration_hours', type: 'integer', example: 40),
                    new OA\Property(property: 'status', type: 'string', enum: ['draft', 'published', 'archived'], example: 'draft'),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 201, description: 'Course created successfully'),
            new OA\Response(response: 422, description: 'Validation error'),
            new OA\Response(response: 401, description: 'Unauthenticated'),
        ]
    )]
    public function store(StoreCourseRequest $request)
    {
        $course = $this->courseService->create(CourseData::fromArray($request->validated()));

        return $this->success(new CourseResource($course), 'Tạo khóa học thành công', 201);
    }

    #[OA\Put(
        path: '/api/v1/courses/{course}',
        operationId: 'updateCourse',
        tags: ['Courses'],
        summary: 'Update an existing course',
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'course', in: 'path', required: true, description: 'Course ID', schema: new OA\Schema(type: 'integer')),
        ],
        requestBody: new OA\RequestBody(
            required: true,
            content: new OA\JsonContent(
                properties: [
                    new OA\Property(property: 'title', type: 'string', example: 'Lập trình Laravel nâng cao'),
                    new OA\Property(property: 'description', type: 'string', example: 'Cập nhật nội dung khóa học'),
                    new OA\Property(property: 'instructor_id', type: 'integer', example: 1),
                    new OA\Property(property: 'price', type: 'number', format: 'float', example: 599000),
                    new OA\Property(property: 'duration_hours', type: 'integer', example: 45),
                    new OA\Property(property: 'status', type: 'string', enum: ['draft', 'published', 'archived'], example: 'published'),
                ]
            )
        ),
        responses: [
            new OA\Response(response: 200, description: 'Course updated successfully'),
            new OA\Response(response: 403, description: 'Unauthorized'),
            new OA\Response(response: 404, description: 'Course not found'),
            new OA\Response(response: 422, description: 'Validation error'),
        ]
    )]
    public function update(UpdateCourseRequest $request, Course $course)
    {
        $this->authorize('update', $course);

        $updated = $this->courseService->update($course, CourseData::fromArray($request->validated()));

        return $this->success(new CourseResource($updated), 'Cập nhật thành công');
    }

    #[OA\Delete(
        path: '/api/v1/courses/{course}',
        operationId: 'deleteCourse',
        tags: ['Courses'],
        summary: 'Delete a course',
        security: [['bearerAuth' => []]],
        parameters: [
            new OA\Parameter(name: 'course', in: 'path', required: true, description: 'Course ID', schema: new OA\Schema(type: 'integer')),
        ],
        responses: [
            new OA\Response(response: 200, description: 'Course deleted successfully'),
            new OA\Response(response: 403, description: 'Unauthorized'),
            new OA\Response(response: 404, description: 'Course not found'),
        ]
    )]
    public function destroy(Course $course)
    {
        $this->authorize('delete', $course);

        $this->courseService->delete($course);

        return $this->success(null, 'Xóa thành công');
    }
}
