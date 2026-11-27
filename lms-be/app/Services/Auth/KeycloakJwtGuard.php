<?php

namespace App\Services\Auth;

use App\Services\Contracts\AuthServiceInterface;
use App\Services\Database\PostgresContextService;
use Illuminate\Auth\GuardHelpers;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Guard;
use Illuminate\Http\Request;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Throwable;

class KeycloakJwtGuard implements Guard
{
    use GuardHelpers;

    private ?object $tokenPayload = null;

    public function __construct(
        private readonly KeycloakJwksService $jwksService,
        private readonly AuthServiceInterface $authService,
        private readonly AuthCookieService $cookieService,
        private Request $request,
    ) {}

    public function setRequest(Request $request): static
    {
        $this->request = $request;
        if ($this->tokenPayload !== null) {
            $this->user = null;
            $this->tokenPayload = null;
        }

        return $this;
    }

    public function user(): ?Authenticatable
    {
        if ($this->user !== null) {
            return $this->user;
        }

        ['token' => $token, 'source' => $source] = $this->cookieService->extractAccessTokenWithSource($this->request);
        if (! $token) {
            return null;
        }

        if (
            $source === 'cookie'
            && ! in_array(strtoupper($this->request->getMethod()), ['GET', 'HEAD', 'OPTIONS'], true)
            && ! $this->cookieService->isTrustedBrowserOrigin($this->request)
        ) {
            throw new AccessDeniedHttpException('Yêu cầu xác thực qua Cookie từ nguồn (Origin) không hợp lệ.');
        }

        try {
            $payload = $this->jwksService->decodeToken($token);
            $this->tokenPayload = $payload;

            $roles = $this->authService->extractRolesFromPayload($payload);
            $primaryRole = $this->authService->resolvePrimaryRole($roles);

            $user = $this->authService->syncUserWithDatabase($payload, $primaryRole);
            if (! $user->is_active) {
                return null;
            }

            $schoolId = (int) ($payload->school_id ?? 0) ?: (int) $user->school_id;

            $user->setConnection('pgsql');
            $user->setAttribute('jwt_role', $primaryRole);
            $user->setAttribute('jwt_roles', $roles);
            $user->setAttribute('jwt_school_id', $schoolId);

            PostgresContextService::setContext(
                schoolId: $schoolId,
                userId: (int) $user->id,
                role: $primaryRole
            );

            return $this->user = $user;
        } catch (Throwable $e) {
            report($e);

            return null;
        }
    }

    /**
     * @param  array<string, mixed>  $credentials
     */
    public function validate(array $credentials = []): bool
    {
        return false;
    }

    public function getTokenPayload(): ?object
    {
        return $this->tokenPayload;
    }
}

