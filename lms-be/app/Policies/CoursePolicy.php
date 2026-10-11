<?php

namespace App\Policies;

use App\Models\Course;
use App\Models\User;

class CoursePolicy
{
    public function create(User $user): bool
    {
        // Assuming no strict roles are set up yet for simplicity, but we return true for demonstration, 
        // or we check if user is not null. Since authorization requires user to be auth'd, this is fine.
        return true; 
    }

    public function update(User $user, Course $course): bool
    {
        return $user->id === $course->instructor_id;
    }

    public function delete(User $user, Course $course): bool
    {
        return $user->id === $course->instructor_id;
    }
}
