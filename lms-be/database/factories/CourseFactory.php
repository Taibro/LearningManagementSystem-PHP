<?php

namespace Database\Factories;

use App\Enums\CourseStatus;
use App\Models\Course;
use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Course>
 */
class CourseFactory extends Factory
{
    protected $model = Course::class;

    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        $title = $this->faker->sentence;

        return [
            'title' => $title,
            'slug' => Str::slug($title),
            'description' => $this->faker->paragraph,
            'instructor_id' => User::factory(),
            'price' => $this->faker->randomFloat(2, 10, 500),
            'duration_hours' => $this->faker->numberBetween(1, 100),
            'status' => $this->faker->randomElement([CourseStatus::Draft, CourseStatus::Published, CourseStatus::Archived]),
        ];
    }
}
