<?php

namespace App\Http\Controllers;

use OpenApi\Attributes as OA;

#[OA\Info(
    version: '1.0.0',
    title: 'LMS API Documentation',
    description: 'API documentation for Learning Management System (LMS) Backend',
    contact: new OA\Contact(name: 'LMS Team', email: 'support@lms.local')
)]
#[OA\Server(
    url: '/',
    description: 'Current Environment Server'
)]
#[OA\SecurityScheme(
    securityScheme: 'bearerAuth',
    type: 'http',
    scheme: 'bearer',
    bearerFormat: 'JWT',
    description: 'Enter Sanctum API token or Bearer token'
)]
#[OA\Post(
    path: '/login',
    operationId: 'authLogin',
    tags: ['Authentication'],
    summary: 'Log in user',
    description: 'Authenticate user with email and password',
    requestBody: new OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['email', 'password'],
            properties: [
                new OA\Property(property: 'email', type: 'string', format: 'email', example: 'user@example.com'),
                new OA\Property(property: 'password', type: 'string', format: 'password', example: 'password'),
                new OA\Property(property: 'remember', type: 'boolean', example: false),
            ]
        )
    ),
    responses: [
        new OA\Response(response: 200, description: 'Login successful'),
        new OA\Response(response: 422, description: 'Invalid credentials or validation error'),
    ]
)]
#[OA\Post(
    path: '/register',
    operationId: 'authRegister',
    tags: ['Authentication'],
    summary: 'Register a new user',
    description: 'Create a new user account and personal team',
    requestBody: new OA\RequestBody(
        required: true,
        content: new OA\JsonContent(
            required: ['name', 'email', 'password', 'password_confirmation'],
            properties: [
                new OA\Property(property: 'name', type: 'string', example: 'Nguyen Van A'),
                new OA\Property(property: 'email', type: 'string', format: 'email', example: 'user@example.com'),
                new OA\Property(property: 'password', type: 'string', format: 'password', example: 'Password123!'),
                new OA\Property(property: 'password_confirmation', type: 'string', format: 'password', example: 'Password123!'),
            ]
        )
    ),
    responses: [
        new OA\Response(response: 201, description: 'User registered successfully'),
        new OA\Response(response: 422, description: 'Validation error'),
    ]
)]
#[OA\Post(
    path: '/logout',
    operationId: 'authLogout',
    tags: ['Authentication'],
    summary: 'Log out user',
    security: [['bearerAuth' => []]],
    responses: [
        new OA\Response(response: 204, description: 'Logged out successfully'),
        new OA\Response(response: 200, description: 'Logged out successfully'),
    ]
)]
#[OA\Get(
    path: '/api/user',
    operationId: 'getAuthenticatedUser',
    tags: ['Authentication'],
    summary: 'Get current authenticated user',
    security: [['bearerAuth' => []]],
    responses: [
        new OA\Response(response: 200, description: 'User profile retrieved successfully'),
        new OA\Response(response: 401, description: 'Unauthenticated'),
    ]
)]
abstract class Controller
{
    //
}
