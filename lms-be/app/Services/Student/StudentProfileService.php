<?php

namespace App\Services\Student;

use App\DTOs\Student\StudentProfileResponseDto;
use App\DTOs\Student\UpdateStudentProfileRequestDto;
use App\Models\ImageUpload;
use App\Models\Student;
use App\Models\User;
use App\Repositories\Contracts\RepositoryWrapperInterface;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

class StudentProfileService
{
    public function __construct(
        private readonly RepositoryWrapperInterface $repositories,
    ) {}

    /**
     * Retrieve the authenticated student's profile within their tenant school.
     */
    public function getProfile(User $user): StudentProfileResponseDto
    {
        $schoolId = $this->resolveSchoolId($user);
        $student = $this->repositories->students()->findProfileByUserId((int) $user->id, $schoolId);

        if ($student === null) {
            throw new NotFoundHttpException('Không tìm thấy hồ sơ sinh viên.');
        }

        return $this->mapToResponseDto($student, $user);
    }

    /**
     * Atomically update only allowed personal contact fields for the authenticated student.
     */
    public function updateProfile(User $user, UpdateStudentProfileRequestDto $dto): StudentProfileResponseDto
    {
        $schoolId = $this->resolveSchoolId($user);
        $student = $this->repositories->students()->findProfileByUserId((int) $user->id, $schoolId);

        if ($student === null) {
            throw new NotFoundHttpException('Không tìm thấy hồ sơ sinh viên.');
        }

        if ($this->repositories->users()->existsByEmailInSchoolExceptUser($dto->email, $schoolId, (int) $user->id)) {
            throw ValidationException::withMessages([
                'email' => ['Email này đã được sử dụng bởi tài khoản khác trong cùng trường.'],
            ]);
        }

        $resolvedAvatarUploadId = $this->resolveValidatedAvatarUploadId($user, $schoolId, $dto);

        return $this->repositories->transaction(function () use ($user, $student, $dto, $resolvedAvatarUploadId): StudentProfileResponseDto {
            $userData = [
                'email' => $dto->email,
                'phone' => $dto->phone,
                'updated_by' => (int) $user->id,
            ];

            if ($dto->hasAvatarUploadId()) {
                $userData['avatar_upload_id'] = $resolvedAvatarUploadId;
            }

            $updatedUser = $this->repositories->users()->updateContact($user, $userData);

            $studentData = [
                'address' => $dto->address,
                'updated_by' => (int) $user->id,
            ];

            if ($dto->gender !== null) {
                $studentData['gender'] = $dto->gender;
            }

            $updatedStudent = $this->repositories->students()->updateProfile($student, $studentData);

            return $this->mapToResponseDto($updatedStudent, $updatedUser);
        });
    }

    private function resolveValidatedAvatarUploadId(
        User $user,
        int $schoolId,
        UpdateStudentProfileRequestDto $dto
    ): ?int {
        if (! $dto->hasAvatarUploadId() || $dto->avatarUploadId === null) {
            return null;
        }

        $upload = $this->repositories->imageUploads()->findByIdForSchool($dto->avatarUploadId, $schoolId);

        if ($upload === null) {
            throw ValidationException::withMessages([
                'avatarUploadId' => ['Ảnh đại diện không tồn tại hoặc không thuộc trường của bạn.'],
            ]);
        }

        if ($upload->category !== ImageUpload::CATEGORY_AVATAR) {
            throw ValidationException::withMessages([
                'avatarUploadId' => ['Tệp được chọn không thuộc danh mục ảnh đại diện (AVATAR).'],
            ]);
        }

        if ($upload->status !== ImageUpload::STATUS_UPLOADED) {
            throw ValidationException::withMessages([
                'avatarUploadId' => ['Ảnh đại diện chưa hoàn tất xác nhận tải lên (UPLOADED).'],
            ]);
        }

        if ($upload->uploaded_by !== null && (int) $upload->uploaded_by !== (int) $user->id) {
            throw ValidationException::withMessages([
                'avatarUploadId' => ['Bạn không có quyền sử dụng tệp ảnh đại diện của người dùng khác.'],
            ]);
        }

        return (int) $upload->id;
    }

    private function resolveSchoolId(User $user): int
    {
        return (int) ($user->getAttribute('jwt_school_id') ?: $user->school_id);
    }

    private function mapToResponseDto(Student $student, User $fallbackUser): StudentProfileResponseDto
    {
        $profileUser = $student->user ?? $fallbackUser;

        return new StudentProfileResponseDto(
            id: (int) $student->id,
            studentCode: (string) $student->student_code,
            fullName: (string) $profileUser->full_name,
            gender: $student->gender,
            dateOfBirth: $student->date_of_birth?->format('Y-m-d'),
            citizenIdNumber: $student->citizen_id_number,
            email: (string) $profileUser->email,
            phone: $profileUser->phone,
            address: $student->address,
            avatarUrl: $profileUser->resolveAvatarUrl(),
            className: $student->administrativeclass,
            major: $student->major,
            degreeLevel: $student->degreelevel,
            trainingType: $student->trainingtype,
            departmentId: $student->department_id !== null ? (int) $student->department_id : null,
            departmentName: $student->department?->name,
            enrollmentYear: $student->enrollment_date?->year,
            enrollmentStatus: (string) $student->enrollment_status,
            schoolName: $student->school?->name,
        );
    }
}
