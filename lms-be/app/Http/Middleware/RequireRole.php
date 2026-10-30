<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class RequireRole
{
    /**
     * Ensure the authenticated user has at least one of the required roles.
     */
    public function handle(Request $request, Closure $next, string ...$roles): Response
    {
        $user = $request->user();
        if (! $user) {
            return response()->json(['message' => 'Unauthenticated.'], 401);
        }

        $jwtRoles = (array) ($user->getAttribute('jwt_roles') ?? [$user->getAttribute('jwt_role')]);
        if (in_array('SAAS_ADMIN', $jwtRoles, true)) {
            return $next($request);
        }

        $normalizedRequired = array_map(fn (string $r) => strtoupper(trim($r)), $roles);
        foreach ($jwtRoles as $userRole) {
            if (in_array(strtoupper((string) $userRole), $normalizedRequired, true)) {
                return $next($request);
            }
        }

        return response()->json([
            'message' => 'Bạn không có quyền truy cập tài nguyên này.',
        ], 403);
    }
}

