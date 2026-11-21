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
abstract class Controller
{
    /**
     * Base prefix for versioned API endpoints.
     */
    protected const API_PREFIX = '/api/{version}';
}
