<?php

namespace App\Http\Controllers;

use App\DTOs\Common\HealthCheckResponseDto;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use OpenApi\Attributes as OA;
use Throwable;

#[OA\Tag(name: 'System', description: 'System monitoring and health check endpoints')]
class HealthController extends Controller
{
    #[OA\Get(
        path: self::API_PREFIX . '/health',
        operationId: 'systemHealthCheck',
        tags: ['System'],
        summary: 'Check application, database, and cache health',
        parameters: [
            new OA\Parameter(
                name: 'version',
                in: 'path',
                required: true,
                description: 'API version (e.g. v1)',
                schema: new OA\Schema(type: 'string', default: 'v1')
            ),
        ],
        responses: [
            new OA\Response(
                response: 200,
                description: 'System is healthy',
                content: new OA\JsonContent(ref: HealthCheckResponseDto::class)
            ),
            new OA\Response(
                response: 503,
                description: 'One or more critical dependencies are unhealthy',
                content: new OA\JsonContent(ref: HealthCheckResponseDto::class)
            ),
        ]
    )]
    public function __invoke(): JsonResponse
    {
        $checks = [
            'app' => 'healthy',
            'database' => 'healthy',
            'cache' => 'healthy',
        ];

        $isHealthy = true;

        try {
            DB::connection()->getPdo();
        } catch (Throwable) {
            $checks['database'] = 'unhealthy';
            $isHealthy = false;
        }

        try {
            $probeKey = 'health_check_probe';
            Cache::put($probeKey, 'ok', 10);
            if (Cache::get($probeKey) !== 'ok') {
                $checks['cache'] = 'degraded';
            }
        } catch (Throwable) {
            $checks['cache'] = 'degraded';
        }

        return response()->json(
            new HealthCheckResponseDto(
                status: $isHealthy ? 'healthy' : 'unhealthy',
                timestamp: now()->toIso8601String(),
                checks: $checks,
            ),
            $isHealthy ? 200 : 503
        );
    }
}
