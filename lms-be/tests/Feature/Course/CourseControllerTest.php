<?php

namespace Tests\Feature\Course;

use App\Models\Course;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class CourseControllerTest extends TestCase
{
    use RefreshDatabase;

    public function test_authenticated_user_can_list_courses(): void
    {
        $user = User::factory()->create();
        Course::factory()->count(5)->create();

        $this->actingAs($user)
            ->getJson('/api/v1/courses')
            ->assertOk()
            ->assertJsonStructure(['data' => ['*' => ['id', 'title', 'slug', 'price']]]);
    }

    public function test_instructor_can_create_course(): void
    {
        $instructor = User::factory()->create();

        $this->actingAs($instructor)
            ->postJson('/api/v1/courses', [
                'title'          => 'Laravel API Design',
                'description'    => 'Học kiến trúc API chuẩn doanh nghiệp',
                'instructor_id'  => $instructor->id,
                'price'          => 499000,
                'duration_hours' => 12,
            ])
            ->assertCreated()
            ->assertJsonPath('data.title', 'Laravel API Design');

        $this->assertDatabaseHas('courses', ['title' => 'Laravel API Design']);
    }

    public function test_returns_404_for_missing_course(): void
    {
        $user = User::factory()->create();

        $this->actingAs($user)
            ->getJson('/api/v1/courses/9999')
            ->assertNotFound();
    }
}
