<?php

namespace App\Exceptions;

use Exception;

class CourseNotFoundException extends Exception
{
    public function __construct(int $id)
    {
        parent::__construct("Course with ID {$id} not found.");
    }

    public function render()
    {
        return response()->json([
            'success' => false,
            'message' => $this->getMessage(),
        ], 404);
    }
}
