<?php

namespace App\Services\Auth;

use App\Services\Database\PostgresContextService;
use Illuminate\Auth\GuardHelpers;
use Illuminate\Contracts\Auth\Authenticatable;
use Illuminate\Contracts\Auth\Guard;
use Illuminate\Http\Request;
use Throwable;

class KeycloakJwtGuard implements Guard
{
    use GuardHelpers;

    private ?object $tokenPayload = null;

    public function __construct(
        private readonly KeycloakJwksService $jwksService,
        private readonly KeycloakAuthService $authService,
        private readonly Request $request,
    ) {}

    public function user(): ?Authenticatable
    {
        if ($this->user !== null) {
            return $this->user;
        }

        $bearer = $this->request->bearerToken();
        if (! $bearer) {
            return null;
        }

        try {
            $payload = $this->jwksService->decodeToken($bearer);
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

    public function validate(array $credentials = []): bool
    {
        return false;
    }

    public function getTokenPayload(): ?object
    {
        return $this->tokenPayload;
    }
}

