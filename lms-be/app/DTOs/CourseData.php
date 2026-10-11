<?php

namespace App\DTOs;

use App\Enums\CourseStatus;
use Illuminate\Support\Str;

final class CourseData
{
    public function __construct(
        public readonly string $title,
        public readonly string $description,
        public readonly int $instructorId,
        public readonly float $price,
        public readonly int $durationHours,
        public readonly CourseStatus $status = CourseStatus::Draft,
    ) {}

    public static function fromArray(array $validated): self
    {
        return new self(
            title: $validated['title'],
            description: $validated['description'],
            instructorId: $validated['instructor_id'],
            price: (float) $validated['price'],
            durationHours: (int) $validated['duration_hours'],
            status: CourseStatus::from($validated['status'] ?? 'draft'),
        );
    }

    public function toArray(): array
    {
        return [
            'title' => $this->title,
            'slug' => Str::slug($this->title),
            'description' => $this->description,
            'instructor_id' => $this->instructorId,
            'price' => $this->price,
            'duration_hours' => $this->durationHours,
            'status' => $this->status->value,
        ];
    }
}
