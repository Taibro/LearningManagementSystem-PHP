<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Str;
use Symfony\Component\HttpFoundation\Response;

class RequestLoggingMiddleware
{
    public function handle(Request $request, Closure $next): Response
    {
        $requestId = (string) ($request->header('X-Request-Id') ?: Str::uuid());
        $request->attributes->set('request_id', $requestId);

        $startedAt = hrtime(true);

        /** @var Response $response */
        $response = $next($request);

        $durationMs = round((hrtime(true) - $startedAt) / 1_000_000, 2);
        $statusCode = $response->getStatusCode();

        $response->headers->set('X-Request-Id', $requestId);

        $context = [
            'request_id' => $requestId,
            'method' => $request->getMethod(),
            'path' => $request->getPathInfo(),
            'status' => $statusCode,
            'duration_ms' => $durationMs,
            'ip' => $request->ip(),
            'user_id' => $request->user()?->getAuthIdentifier(),
        ];

        if ($statusCode >= 500) {
            Log::error('HTTP Request Error', $context);
        } elseif ($statusCode >= 400) {
            Log::warning('HTTP Request Warning', $context);
        } else {
            Log::info('HTTP Request Completed', $context);
        }

        return $response;
    }
}
