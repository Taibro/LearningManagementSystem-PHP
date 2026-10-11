<?php

namespace App\Repositories\Eloquent;

use App\Models\Course;
use App\Repositories\Contracts\CourseRepositoryInterface;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class CourseRepository implements CourseRepositoryInterface
{
    public function paginate(array $filters = [], int $perPage = 15): LengthAwarePaginator
    {
        return Course::query()
            ->with('instructor')
            ->when($filters['status'] ?? null, fn ($q, $status) => $q->where('status', $status))
            ->when($filters['search'] ?? null, fn ($q, $search) => $q->where('title', 'like', "%{$search}%"))
            ->latest()
            ->paginate($perPage);
    }

    public function findById(int $id): ?Course
    {
        return Course::find($id);
    }

    public function create(array $data): Course
    {
        return Course::create($data);
    }

    public function update(Course $course, array $data): Course
    {
        $course->update($data);
        return $course->fresh();
    }

    public function delete(Course $course): bool
    {
        return $course->delete();
    }
}
