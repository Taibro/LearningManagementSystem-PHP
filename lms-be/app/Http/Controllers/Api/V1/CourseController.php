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

class CourseController extends Controller
{
    use ApiResponse;

    public function __construct(
        private readonly CourseService $courseService,
    ) {}

    public function index(Request $request)
    {
        $courses = $this->courseService->list(
            filters: $request->only(['status', 'search']),
            perPage: (int) $request->get('per_page', 15),
        );

        return CourseResource::collection($courses);
    }

    public function show(int $id)
    {
        return $this->success(new CourseResource($this->courseService->find($id)));
    }

    public function store(StoreCourseRequest $request)
    {
        $course = $this->courseService->create(CourseData::fromArray($request->validated()));

        return $this->success(new CourseResource($course), 'Tạo khóa học thành công', 201);
    }

    public function update(UpdateCourseRequest $request, Course $course)
    {
        $this->authorize('update', $course);

        $updated = $this->courseService->update($course, CourseData::fromArray($request->validated()));

        return $this->success(new CourseResource($updated), 'Cập nhật thành công');
    }

    public function destroy(Course $course)
    {
        $this->authorize('delete', $course);

        $this->courseService->delete($course);

        return $this->success(null, 'Xóa thành công');
    }
}
