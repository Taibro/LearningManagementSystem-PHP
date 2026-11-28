<?php

use App\Http\Controllers\Student\StudentProfileController;
use App\Models\Department;
use App\Models\ImageUpload;
use App\Models\School;
use App\Models\Student;
use App\Models\User;
use App\Repositories\Contracts\ImageUploadRepositoryInterface;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use App\Repositories\Contracts\StudentRepositoryInterface;
use App\Repositories\Contracts\UserRepositoryInterface;
use App\Services\Student\StudentProfileService;
use Carbon\CarbonImmutable;

function makeStudentUser(int $id = 5, int $schoolId = 1, array $roles = ['STUDENT']): User
{
    $user = new User;
    $user->id = $id;
    $user->school_id = $schoolId;
    $user->full_name = 'Nguyễn Thành Tài';
    $user->email = 'ntai8448@gmail.com';
    $user->phone = '0901000005';
    $user->avatar_upload_id = null;
    $user->is_active = true;
    $user->setAttribute('jwt_role', $roles[0] ?? 'STUDENT');
    $user->setAttribute('jwt_roles', $roles);
    $user->setAttribute('jwt_school_id', $schoolId);

    return $user;
}

function makeStudentRecord(User $user): Student
{
    $school = new School;
    $school->id = (int) $user->school_id;
    $school->code = 'HUIT';
    $school->name = 'Trường ĐH Công Thương TP.HCM';

    $department = new Department;
    $department->id = 1;
    $department->school_id = (int) $user->school_id;
    $department->code = 'FIT';
    $department->name = 'Khoa Công nghệ Thông tin';

    $student = new Student;
    $student->id = 1;
    $student->school_id = (int) $user->school_id;
    $student->user_id = (int) $user->id;
    $student->department_id = 1;
    $student->student_code = '2001230773';
    $student->gender = 'MALE';
    $student->date_of_birth = CarbonImmutable::parse('2005-05-15');
    $student->citizen_id_number = '079205001234';
    $student->address = 'Tân Phú, TP.HCM';
    $student->administrativeclass = '14DHTH01';
    $student->major = 'Công nghệ thông tin';
    $student->degreelevel = 'Đại học';
    $student->trainingtype = 'Chính quy';
    $student->enrollment_date = CarbonImmutable::parse('2023-09-01');
    $student->enrollment_status = 'ENROLLED';
    $student->setRelation('user', $user);
    $student->setRelation('department', $department);
    $student->setRelation('school', $school);

    return $student;
}

test('StudentProfileController depends only on StudentProfileService', function () {
    $reflection = new ReflectionClass(StudentProfileController::class);
    $params = $reflection->getConstructor()?->getParameters() ?? [];

    expect($params)->toHaveCount(1);

    $type = $params[0]->getType();
    expect($type)->toBeInstanceOf(ReflectionNamedType::class)
        ->and($type->getName())->toBe(StudentProfileService::class);
});

test('Student profile endpoints reject unauthenticated requests with 401', function () {
    $this->getJson('/api/v1/student/profile')
        ->assertStatus(401)
        ->assertJsonStructure(['message', 'requestId']);

    $this->putJson('/api/v1/student/profile', [
        'email' => 'new@gmail.com',
        'phone' => '0909999999',
    ])->assertStatus(401)
        ->assertJsonStructure(['message', 'requestId']);
});

test('Student profile endpoints reject non-student roles with 403', function () {
    $lecturer = makeStudentUser(id: 3, schoolId: 1, roles: ['LECTURER']);

    $this->actingAs($lecturer, 'api')
        ->getJson('/api/v1/student/profile')
        ->assertStatus(403)
        ->assertJson([
            'message' => 'Bạn không có quyền truy cập tài nguyên này.',
        ]);

    $this->actingAs($lecturer, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => 'lecturer@huit.edu.vn',
            'phone' => '0901000004',
        ])
        ->assertStatus(403);
});

test('GET /api/v1/student/profile returns authenticated student 19-field DTO ignoring client ids', function () {
    $user = makeStudentUser();
    $student = makeStudentRecord($user);

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')
        ->once()
        ->with(5, 1)
        ->andReturn($student);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')
        ->once()
        ->andReturn($studentRepo);

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $response = $this->actingAs($user, 'api')
        ->getJson('/api/v1/student/profile?studentId=999&schoolId=999');

    $response->assertOk()
        ->assertExactJson([
            'id' => 1,
            'studentCode' => '2001230773',
            'fullName' => 'Nguyễn Thành Tài',
            'gender' => 'MALE',
            'dateOfBirth' => '2005-05-15',
            'citizenIdNumber' => '079205001234',
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'address' => 'Tân Phú, TP.HCM',
            'avatarUrl' => null,
            'className' => '14DHTH01',
            'major' => 'Công nghệ thông tin',
            'degreeLevel' => 'Đại học',
            'trainingType' => 'Chính quy',
            'departmentId' => 1,
            'departmentName' => 'Khoa Công nghệ Thông tin',
            'enrollmentYear' => 2023,
            'enrollmentStatus' => 'ENROLLED',
            'schoolName' => 'Trường ĐH Công Thương TP.HCM',
        ]);
});

test('GET /api/v1/student/profile returns 404 when student profile does not exist', function () {
    $user = makeStudentUser();

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')
        ->once()
        ->with(5, 1)
        ->andReturn(null);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')
        ->once()
        ->andReturn($studentRepo);

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $this->actingAs($user, 'api')
        ->getJson('/api/v1/student/profile')
        ->assertStatus(404)
        ->assertJsonStructure(['message', 'requestId']);
});

test('PUT /api/v1/student/profile validates required email, phone, and gender enum', function () {
    $user = makeStudentUser();

    $this->actingAs($user, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => 'not-an-email',
            'phone' => '',
            'gender' => 'INVALID',
        ])
        ->assertStatus(422)
        ->assertJsonStructure([
            'message',
            'errors' => ['email', 'phone', 'gender'],
            'requestId',
        ]);
});

test('PUT /api/v1/student/profile rejects duplicate email used by another user in same school', function () {
    $user = makeStudentUser();
    $student = makeStudentRecord($user);

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')
        ->once()
        ->with(5, 1)
        ->andReturn($student);

    $userRepo = Mockery::mock(UserRepositoryInterface::class);
    $userRepo->shouldReceive('existsByEmailInSchoolExceptUser')
        ->once()
        ->with('taken@huit.edu.vn', 1, 5)
        ->andReturn(true);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')->once()->andReturn($studentRepo);
    $repoWrapper->shouldReceive('users')->once()->andReturn($userRepo);

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $this->actingAs($user, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => 'Taken@huit.edu.vn',
            'phone' => '0901000005',
            'gender' => 'MALE',
            'address' => '140 Lê Trọng Tấn',
        ])
        ->assertStatus(422)
        ->assertJsonPath('errors.email.0', 'Email này đã được sử dụng bởi tài khoản khác trong cùng trường.');
});

test('PUT /api/v1/student/profile updates whitelisted fields inside transaction and ignores protected fields', function () {
    $user = makeStudentUser();
    $student = makeStudentRecord($user);

    $updatedUser = clone $user;
    $updatedUser->email = 'updated@huit.edu.vn';
    $updatedUser->phone = '0912345678';

    $updatedStudent = clone $student;
    $updatedStudent->gender = 'FEMALE';
    $updatedStudent->address = '140 Lê Trọng Tấn, Tân Phú, TP.HCM';
    $updatedStudent->setRelation('user', $updatedUser);

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')
        ->once()
        ->with(5, 1)
        ->andReturn($student);
    $studentRepo->shouldReceive('updateProfile')
        ->once()
        ->with($student, [
            'address' => '140 Lê Trọng Tấn, Tân Phú, TP.HCM',
            'updated_by' => 5,
            'gender' => 'FEMALE',
        ])
        ->andReturn($updatedStudent);

    $userRepo = Mockery::mock(UserRepositoryInterface::class);
    $userRepo->shouldReceive('existsByEmailInSchoolExceptUser')
        ->once()
        ->with('updated@huit.edu.vn', 1, 5)
        ->andReturn(false);
    $userRepo->shouldReceive('updateContact')
        ->once()
        ->with($user, [
            'email' => 'updated@huit.edu.vn',
            'phone' => '0912345678',
            'updated_by' => 5,
        ])
        ->andReturn($updatedUser);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')->twice()->andReturn($studentRepo);
    $repoWrapper->shouldReceive('users')->twice()->andReturn($userRepo);
    $repoWrapper->shouldReceive('transaction')
        ->once()
        ->andReturnUsing(static fn (Closure $callback) => $callback());

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $response = $this->actingAs($user, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => '  UPDATED@HUIT.EDU.VN ',
            'phone' => ' 0912345678 ',
            'gender' => 'FEMALE',
            'address' => ' 140 Lê Trọng Tấn, Tân Phú, TP.HCM ',
            'studentCode' => 'HACK999',
            'departmentId' => 999,
            'schoolId' => 999,
            'major' => 'Hacked Major',
            'enrollmentStatus' => 'GRADUATED',
        ]);

    $response->assertOk()
        ->assertJson([
            'id' => 1,
            'studentCode' => '2001230773',
            'email' => 'updated@huit.edu.vn',
            'phone' => '0912345678',
            'gender' => 'FEMALE',
            'address' => '140 Lê Trọng Tấn, Tân Phú, TP.HCM',
            'departmentId' => 1,
            'major' => 'Công nghệ thông tin',
            'enrollmentStatus' => 'ENROLLED',
        ]);
});

test('PUT /api/v1/student/profile links confirmed AVATAR ImageUpload via avatar_upload_id and resolves avatarUrl', function () {
    config([
        'filesystems.disks.r2.url' => 'https://cdn.example.r2.dev',
    ]);

    $user = makeStudentUser();
    $student = makeStudentRecord($user);

    $upload = new ImageUpload([
        'image_uploads_id' => '44444444-4444-4444-8444-444444444444',
        'school_id' => 1,
        'uploaded_by' => 5,
        'disk' => 'r2',
        'bucket' => 'lms-bucket',
        'object_key' => 'schools/1/avatar/2026/11/avatar-5.png',
        'original_name' => 'avatar-5.png',
        'mime_type' => 'image/png',
        'file_size' => 10240,
        'category' => ImageUpload::CATEGORY_AVATAR,
        'visibility' => ImageUpload::VISIBILITY_PUBLIC,
        'status' => ImageUpload::STATUS_UPLOADED,
    ]);
    $upload->id = 42;

    $updatedUser = clone $user;
    $updatedUser->avatar_upload_id = 42;
    $updatedUser->setRelation('avatarUpload', $upload);

    $updatedStudent = clone $student;
    $updatedStudent->setRelation('user', $updatedUser);

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')->once()->with(5, 1)->andReturn($student);
    $studentRepo->shouldReceive('updateProfile')->once()->andReturn($updatedStudent);

    $userRepo = Mockery::mock(UserRepositoryInterface::class);
    $userRepo->shouldReceive('existsByEmailInSchoolExceptUser')->once()->with('ntai8448@gmail.com', 1, 5)->andReturn(false);
    $userRepo->shouldReceive('updateContact')
        ->once()
        ->with($user, [
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'updated_by' => 5,
            'avatar_upload_id' => 42,
        ])
        ->andReturn($updatedUser);

    $uploadRepo = Mockery::mock(ImageUploadRepositoryInterface::class);
    $uploadRepo->shouldReceive('findByIdForSchool')->once()->with(42, 1)->andReturn($upload);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')->twice()->andReturn($studentRepo);
    $repoWrapper->shouldReceive('users')->twice()->andReturn($userRepo);
    $repoWrapper->shouldReceive('imageUploads')->once()->andReturn($uploadRepo);
    $repoWrapper->shouldReceive('transaction')
        ->once()
        ->andReturnUsing(static fn (Closure $callback) => $callback());

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $this->actingAs($user, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'avatarUploadId' => 42,
        ])
        ->assertOk()
        ->assertJsonPath('avatarUrl', 'https://cdn.example.r2.dev/schools/1/avatar/2026/11/avatar-5.png');
});

test('PUT /api/v1/student/profile rejects avatarUploadId when upload is unconfirmed or wrong category', function (string $category, string $status) {
    $user = makeStudentUser();
    $student = makeStudentRecord($user);

    $upload = new ImageUpload([
        'school_id' => 1,
        'uploaded_by' => 5,
        'category' => $category,
        'status' => $status,
    ]);
    $upload->id = 55;

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')->once()->with(5, 1)->andReturn($student);

    $userRepo = Mockery::mock(UserRepositoryInterface::class);
    $userRepo->shouldReceive('existsByEmailInSchoolExceptUser')->once()->with('ntai8448@gmail.com', 1, 5)->andReturn(false);

    $uploadRepo = Mockery::mock(ImageUploadRepositoryInterface::class);
    $uploadRepo->shouldReceive('findByIdForSchool')->once()->with(55, 1)->andReturn($upload);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')->once()->andReturn($studentRepo);
    $repoWrapper->shouldReceive('users')->once()->andReturn($userRepo);
    $repoWrapper->shouldReceive('imageUploads')->once()->andReturn($uploadRepo);

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $this->actingAs($user, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'avatarUploadId' => 55,
        ])
        ->assertStatus(422)
        ->assertJsonValidationErrors(['avatarUploadId']);
})->with([
    'still pending' => [ImageUpload::CATEGORY_AVATAR, ImageUpload::STATUS_PENDING],
    'wrong category' => [ImageUpload::CATEGORY_CLASS_MATERIAL, ImageUpload::STATUS_UPLOADED],
]);

test('PUT /api/v1/student/profile clears avatar_upload_id when avatarUploadId is explicitly null', function () {
    $user = makeStudentUser();
    $user->avatar_upload_id = 42;
    $student = makeStudentRecord($user);

    $updatedUser = clone $user;
    $updatedUser->avatar_upload_id = null;
    $updatedStudent = clone $student;
    $updatedStudent->setRelation('user', $updatedUser);

    $studentRepo = Mockery::mock(StudentRepositoryInterface::class);
    $studentRepo->shouldReceive('findProfileByUserId')->once()->with(5, 1)->andReturn($student);
    $studentRepo->shouldReceive('updateProfile')->once()->andReturn($updatedStudent);

    $userRepo = Mockery::mock(UserRepositoryInterface::class);
    $userRepo->shouldReceive('existsByEmailInSchoolExceptUser')->once()->andReturn(false);
    $userRepo->shouldReceive('updateContact')
        ->once()
        ->with($user, [
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'updated_by' => 5,
            'avatar_upload_id' => null,
        ])
        ->andReturn($updatedUser);

    $repoWrapper = Mockery::mock(RepositoryWrapperInterface::class);
    $repoWrapper->shouldReceive('students')->twice()->andReturn($studentRepo);
    $repoWrapper->shouldReceive('users')->twice()->andReturn($userRepo);
    $repoWrapper->shouldReceive('transaction')
        ->once()
        ->andReturnUsing(static fn (Closure $callback) => $callback());

    $this->app->instance(RepositoryWrapperInterface::class, $repoWrapper);

    $this->actingAs($user, 'api')
        ->putJson('/api/v1/student/profile', [
            'email' => 'ntai8448@gmail.com',
            'phone' => '0901000005',
            'avatarUploadId' => null,
        ])
        ->assertOk()
        ->assertJsonPath('avatarUrl', null);
});
