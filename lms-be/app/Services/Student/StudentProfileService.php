<?php

namespace App\Services\Student;

use App\DTOs\Student\StudentProfileResponseDto;
use App\DTOs\Student\UpdateStudentProfileRequestDto;
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

        return $this->repositories->transaction(function () use ($user, $student, $dto): StudentProfileResponseDto {
            $updatedUser = $this->repositories->users()->updateContact($user, [
                'email' => $dto->email,
                'phone' => $dto->phone,
                'updated_by' => (int) $user->id,
            ]);

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
            avatarUrl: $profileUser->avatar_url,
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
