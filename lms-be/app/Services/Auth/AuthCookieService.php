<?php

namespace App\Services\Auth;

use App\DTOs\Auth\AuthTokenResponseDto;
use App\DTOs\Auth\RefreshTokenResponseDto;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Cookie;

class AuthCookieService
{
    public function accessCookieName(): string
    {
        return (string) config('keycloak.cookie.access_name', 'lms_access_token');
    }

    public function refreshCookieName(): string
    {
        return (string) config('keycloak.cookie.refresh_name', 'lms_refresh_token');
    }

    /**
     * Extract access token and its transport source (Bearer Priority 1, Cookie Priority 2).
     *
     * @return array{token: string|null, source: 'bearer'|'cookie'|null}
     */
    public function extractAccessTokenWithSource(Request $request): array
    {
        $bearer = $request->bearerToken();
        if (is_string($bearer) && trim($bearer) !== '') {
            return [
                'token' => trim($bearer),
                'source' => 'bearer',
            ];
        }

        $cookieToken = $request->cookie($this->accessCookieName());
        if (is_string($cookieToken) && trim($cookieToken) !== '') {
            return [
                'token' => trim($cookieToken),
                'source' => 'cookie',
            ];
        }

        return [
            'token' => null,
            'source' => null,
        ];
    }

    public function extractAccessToken(Request $request): ?string
    {
        return $this->extractAccessTokenWithSource($request)['token'];
    }

    /**
     * Priority 1: Explicit refreshToken in request body.
     * Priority 2: HttpOnly refresh token cookie.
     */
    public function extractRefreshToken(Request $request): ?string
    {
        $bodyToken = $request->input('refreshToken');
        if (is_string($bodyToken) && trim($bodyToken) !== '') {
            return trim($bodyToken);
        }

        $cookieToken = $request->cookie($this->refreshCookieName());
        if (is_string($cookieToken) && trim($cookieToken) !== '') {
            return trim($cookieToken);
        }

        return null;
    }

    /**
     * Enforce Origin/Referer verification for browser state-changing requests authenticated via Cookie.
     * Non-browser API clients (Postman, curl, CLI) that omit both Origin and Referer are permitted.
     */
    public function isTrustedBrowserOrigin(Request $request): bool
    {
        $rawOrigin = $request->headers->get('Origin');
        $rawReferer = $request->headers->get('Referer');

        $hasOrigin = is_string($rawOrigin) && trim($rawOrigin) !== '';
        $hasReferer = is_string($rawReferer) && trim($rawReferer) !== '';

        if (! $hasOrigin && ! $hasReferer) {
            return true;
        }

        $requestOrigin = $hasOrigin
            ? $this->normalizeOrigin($rawOrigin)
            : $this->normalizeOrigin((string) $rawReferer);

        if ($requestOrigin === null) {
            return false;
        }

        $sameOrigin = $this->normalizeOrigin($request->getSchemeAndHttpHost());
        if ($sameOrigin !== null && $requestOrigin === $sameOrigin) {
            return true;
        }

        $allowedOrigins = (array) config('cors.allowed_origins', []);
        foreach ($allowedOrigins as $allowed) {
            if (! is_string($allowed)) {
                continue;
            }

            $normalizedAllowed = $this->normalizeOrigin($allowed);
            if ($normalizedAllowed !== null && $normalizedAllowed === $requestOrigin) {
                return true;
            }
        }

        return false;
    }

    public function shouldHideTokensInBody(Request $request): bool
    {
        if ((bool) config('keycloak.cookie.hide_tokens_in_body', false)) {
            return true;
        }

        return strtolower((string) $request->header('X-Auth-Mode', '')) === 'cookie';
    }

    public function attachAuthCookies(
        JsonResponse $response,
        ?string $accessToken,
        ?string $refreshToken,
        ?int $expiresInSeconds = 900
    ): JsonResponse {
        if ($accessToken !== null && $accessToken !== '') {
            $accessMinutes = max(1, (int) ceil(($expiresInSeconds ?? 900) / 60));
            $response->headers->setCookie($this->makeCookie(
                name: $this->accessCookieName(),
                value: $accessToken,
                minutes: $accessMinutes,
                path: '/',
            ));
        }

        if ($refreshToken !== null && $refreshToken !== '') {
            $refreshMinutes = max(1, (int) config('keycloak.cookie.refresh_ttl_minutes', 60 * 24 * 7));
            $response->headers->setCookie($this->makeCookie(
                name: $this->refreshCookieName(),
                value: $refreshToken,
                minutes: $refreshMinutes,
                path: '/api',
            ));
        }

        return $response;
    }

    public function clearAuthCookies(JsonResponse $response): JsonResponse
    {
        $response->headers->setCookie($this->makeExpiredCookie($this->accessCookieName(), '/'));
        $response->headers->setCookie($this->makeExpiredCookie($this->refreshCookieName(), '/api'));

        return $response;
    }

    public function sanitizeAuthResponse(AuthTokenResponseDto $dto, Request $request): AuthTokenResponseDto
    {
        if (! $this->shouldHideTokensInBody($request)) {
            return $dto;
        }

        return new AuthTokenResponseDto(
            token: null,
            accessToken: null,
            refreshToken: null,
            expiresIn: $dto->expiresIn,
            id: $dto->id,
            userId: $dto->userId,
            usersId: $dto->usersId,
            keycloakId: $dto->keycloakId,
            userCode: $dto->userCode,
            studentCode: $dto->studentCode,
            teacherCode: $dto->teacherCode,
            fullName: $dto->fullName,
            email: $dto->email,
            phone: $dto->phone,
            avatarUrl: $dto->avatarUrl,
            role: $dto->role,
            roles: $dto->roles,
            schoolId: $dto->schoolId,
            schoolCode: $dto->schoolCode,
            schoolName: $dto->schoolName,
            require2fa: $dto->require2fa,
            requireSetup: $dto->requireSetup,
        );
    }

    /**
     * @return RefreshTokenResponseDto|array<string, mixed>
     */
    public function sanitizeRefreshResponse(RefreshTokenResponseDto $dto, Request $request): RefreshTokenResponseDto|array
    {
        if (! $this->shouldHideTokensInBody($request)) {
            return $dto;
        }

        return [
            'token' => null,
            'accessToken' => null,
            'refreshToken' => null,
            'expiresIn' => $dto->expiresIn,
        ];
    }

    private function normalizeOrigin(string $url): ?string
    {
        $trimmed = trim($url);
        if ($trimmed === '' || strtolower($trimmed) === 'null') {
            return null;
        }

        $parts = parse_url($trimmed);
        if (! is_array($parts) || empty($parts['scheme']) || empty($parts['host'])) {
            return null;
        }

        $origin = strtolower((string) $parts['scheme']).'://'.strtolower((string) $parts['host']);
        if (isset($parts['port'])) {
            $origin .= ':'.(int) $parts['port'];
        }

        return $origin;
    }

    private function makeCookie(string $name, string $value, int $minutes, string $path): Cookie
    {
        $domain = config('keycloak.cookie.domain');
        $secure = (bool) config('keycloak.cookie.secure', false);
        $sameSite = (string) config('keycloak.cookie.same_site', 'lax');

        return cookie(
            name: $name,
            value: $value,
            minutes: $minutes,
            path: $path,
            domain: is_string($domain) && $domain !== '' ? $domain : null,
            secure: $secure,
            httpOnly: true,
            raw: false,
            sameSite: $sameSite !== '' ? $sameSite : null,
        );
    }

    private function makeExpiredCookie(string $name, string $path): Cookie
    {
        $domain = config('keycloak.cookie.domain');
        $secure = (bool) config('keycloak.cookie.secure', false);
        $sameSite = (string) config('keycloak.cookie.same_site', 'lax');

        return cookie(
            name: $name,
            value: '',
            minutes: -2628000,
            path: $path,
            domain: is_string($domain) && $domain !== '' ? $domain : null,
            secure: $secure,
            httpOnly: true,
            raw: false,
            sameSite: $sameSite !== '' ? $sameSite : null,
        );
    }
}
