<?php

namespace App\Http\Requests\Course;

use Illuminate\Foundation\Http\FormRequest;

class StoreCourseRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('create', \App\Models\Course::class);
    }

    public function rules(): array
    {
        return [
            'title'          => ['required', 'string', 'max:255'],
            'description'    => ['required', 'string'],
            'instructor_id'  => ['required', 'exists:users,id'],
            'price'          => ['required', 'numeric', 'min:0'],
            'duration_hours' => ['required', 'integer', 'min:1'],
            'status'         => ['sometimes', 'in:draft,published,archived'],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required'         => 'Tiêu đề khóa học là bắt buộc.',
            'instructor_id.exists'   => 'Giảng viên không tồn tại.',
        ];
    }
}
