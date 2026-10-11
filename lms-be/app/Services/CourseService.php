<?php

namespace App\Services;

use App\DTOs\CourseData;
use App\Exceptions\CourseNotFoundException;
use App\Models\Course;
use App\Repositories\Contracts\CourseRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class CourseService
{
    public function __construct(
        private readonly CourseRepositoryInterface $courses,
    ) {}

    public function list(array $filters, int $perPage = 15): LengthAwarePaginator
    {
        return $this->courses->paginate($filters, $perPage);
    }

    public function find(int $id): Course
    {
        return $this->courses->findById($id) ?? throw new CourseNotFoundException($id);
    }

    public function create(CourseData $data): Course
    {
        return DB::transaction(function () use ($data) {
            $course = $this->courses->create($data->toArray());

            Log::info('Course created', ['course_id' => $course->id]);

            // event(new CourseCreated($course)); // ví dụ: gửi notification cho subscriber

            return $course;
        });
    }

    public function update(Course $course, CourseData $data): Course
    {
        return DB::transaction(fn () => $this->courses->update($course, $data->toArray()));
    }

    public function delete(Course $course): bool
    {
        return DB::transaction(fn () => $this->courses->delete($course));
    }
}
