<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CourseResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'title'          => $this->title,
            'slug'           => $this->slug,
            'description'    => $this->description,
            'price'          => (float) $this->price,
            'duration_hours' => $this->duration_hours,
            'status'         => $this->status?->value,
            'instructor'     => new UserResource($this->whenLoaded('instructor')),
            'created_at'     => $this->created_at?->toIso8601String(),
            'updated_at'     => $this->updated_at?->toIso8601String(),
        ];
    }
}
