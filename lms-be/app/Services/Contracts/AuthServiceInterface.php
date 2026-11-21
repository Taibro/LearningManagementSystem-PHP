<?php

namespace App\Services\Contracts;

use App\DTOs\Auth\AuthTokenResponseDto;
use App\DTOs\Auth\LoginRequestDto;
use App\DTOs\Auth\LogoutRequestDto;
use App\DTOs\Auth\RefreshTokenRequestDto;
use App\DTOs\Auth\RefreshTokenResponseDto;
use App\DTOs\Auth\RegisterRequestDto;
use App\DTOs\Auth\SchoolResponseDto;
use App\DTOs\Auth\Setup2faRequestDto;
use App\DTOs\Auth\Setup2faResponseDto;
use App\DTOs\Auth\UserProfileResponseDto;
use App\DTOs\Auth\Verify2faRequestDto;
use App\DTOs\Auth\VerifyLogin2faRequestDto;
use App\DTOs\Auth\VerifyLogin2faResponseDto;
use App\DTOs\Common\MessageResponseDto;
use App\Models\School;
use App\Models\User;

interface AuthServiceInterface
{
    /**
     * Get all active schools mapped to response DTOs.
     *
     * @return array<int, SchoolResponseDto>
     */
    public function getActiveSchools(): array;

    /**
     * Authenticate user credentials and return mapped auth token response DTO.
     */
    public function login(LoginRequestDto $dto): AuthTokenResponseDto;

    /**
     * Register a new user in the identity provider and database and return mapped auth token response DTO.
     */
    public function register(RegisterRequestDto $dto): AuthTokenResponseDto;

    /**
     * Exchange a refresh token for a new access token DTO.
     */
    public function refreshToken(RefreshTokenRequestDto $dto): RefreshTokenResponseDto;

    /**
     * Terminate user session in identity provider and return confirmation message DTO.
     */
    public function logout(LogoutRequestDto $dto): MessageResponseDto;

    /**
     * Map authenticated user model to profile response DTO.
     */
    public function getCurrentUserProfile(User $user): UserProfileResponseDto;

    /**
     * Generate 2FA TOTP QR code setup URI DTO.
     */
    public function setup2fa(Setup2faRequestDto $dto): Setup2faResponseDto;

    /**
     * Verify 6-digit TOTP setup code.
     */
    public function verifySetup2fa(Verify2faRequestDto $dto): bool;

    /**
     * Verify 2FA login challenge and return mapped session DTO.
     */
    public function verifyLogin2fa(
        VerifyLogin2faRequestDto $dto,
        ?User $user = null,
        ?string $token = null
    ): VerifyLogin2faResponseDto;

    /**
     * Synchronize the authenticated JWT user payload into PostgreSQL database.
     */
    public function syncUserWithDatabase(object $payload, string $primaryRole, ?School $school = null): User;

    /**
     * Extract system-recognized roles from JWT payload.
     *
     * @return array<int, string>
     */
    public function extractRolesFromPayload(object $payload): array;

    /**
     * Determine primary role based on system hierarchy.
     *
     * @param  array<int, string>  $roles
     */
    public function resolvePrimaryRole(array $roles): string;
}
