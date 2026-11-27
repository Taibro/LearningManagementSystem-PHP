<?php

use App\DTOs\Common\ErrorResponseDto;
use App\Http\Middleware\RequestLoggingMiddleware;
use App\Http\Middleware\RequireRole;
use App\Http\Middleware\SecurityHeadersMiddleware;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Exceptions\ThrottleRequestsException;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpKernel\Exception\AccessDeniedHttpException;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;
use Symfony\Component\HttpKernel\Exception\NotFoundHttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        $middleware->trustProxies(at: '*');

        $middleware->encryptCookies(except: [
            'lms_access_token',
            'lms_refresh_token',
        ]);

        $middleware->prepend(RequestLoggingMiddleware::class);
        $middleware->append(SecurityHeadersMiddleware::class);

        $middleware->alias([
            'role' => RequireRole::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*') || $request->expectsJson(),
        );

        $isApiRequest = static fn (Request $request): bool => $request->is('api/*') || $request->expectsJson();
        $resolveRequestId = static fn (Request $request): ?string => $request->attributes->get('request_id')
            ?: ($request->header('X-Request-Id') ?: null);

        $exceptions->render(function (ValidationException $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            $firstError = (string) (collect($e->errors())->flatten()->first() ?: 'Dữ liệu không hợp lệ.');

            return response()->json(
                new ErrorResponseDto(
                    message: $firstError,
                    errors: $e->errors(),
                    requestId: $resolveRequestId($request),
                ),
                $e->status
            );
        });

        $exceptions->render(function (AuthenticationException $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            return response()->json(
                new ErrorResponseDto(
                    message: 'Chưa xác thực hoặc phiên đăng nhập không hợp lệ.',
                    requestId: $resolveRequestId($request),
                ),
                401
            );
        });

        $exceptions->render(function (AccessDeniedHttpException $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            return response()->json(
                new ErrorResponseDto(
                    message: $e->getMessage() ?: 'Bạn không có quyền thực hiện thao tác này.',
                    requestId: $resolveRequestId($request),
                ),
                403
            );
        });

        $exceptions->render(function (NotFoundHttpException $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            return response()->json(
                new ErrorResponseDto(
                    message: 'Không tìm thấy tài nguyên hoặc endpoint yêu cầu.',
                    requestId: $resolveRequestId($request),
                ),
                404
            );
        });

        $exceptions->render(function (ThrottleRequestsException $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            return response()->json(
                new ErrorResponseDto(
                    message: 'Bạn đã gửi quá nhiều yêu cầu. Vui lòng thử lại sau.',
                    requestId: $resolveRequestId($request),
                ),
                429
            );
        });

        $exceptions->render(function (HttpExceptionInterface $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            return response()->json(
                new ErrorResponseDto(
                    message: $e->getMessage() ?: 'Yêu cầu không hợp lệ.',
                    requestId: $resolveRequestId($request),
                ),
                $e->getStatusCode()
            );
        });

        $exceptions->render(function (Throwable $e, Request $request) use ($isApiRequest, $resolveRequestId) {
            if (! $isApiRequest($request)) {
                return null;
            }

            $message = app()->isProduction()
                ? 'Đã xảy ra lỗi hệ thống trong quá trình xử lý yêu cầu.'
                : ($e->getMessage() ?: 'Internal Server Error.');

            return response()->json(
                new ErrorResponseDto(
                    message: $message,
                    requestId: $resolveRequestId($request),
                ),
                500
            );
        });
    })->create();
