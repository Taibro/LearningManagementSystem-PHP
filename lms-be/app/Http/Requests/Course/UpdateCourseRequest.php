<?php

namespace App\Http\Requests\Course;

use Illuminate\Foundation\Http\FormRequest;

class UpdateCourseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('update', $this->route('course'));
    }

    public function rules(): array
    {
        return [
            'title'          => ['sometimes', 'string', 'max:255'],
            'description'    => ['sometimes', 'string'],
            'instructor_id'  => ['sometimes', 'exists:users,id'],
            'price'          => ['sometimes', 'numeric', 'min:0'],
            'duration_hours' => ['sometimes', 'integer', 'min:1'],
            'status'         => ['sometimes', 'in:draft,published,archived'],
        ];
    }

    public function messages(): array
    {
        return [
            'instructor_id.exists'   => 'Giảng viên không tồn tại.',
        ];
    }
}
