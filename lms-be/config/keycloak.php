<?php

return [
    'base_url' => rtrim(env('KEYCLOAK_BASE_URL', 'https://auth-dev-api.duckdns.org'), '/'),
    'realm' => env('KEYCLOAK_REALM', 'lms'),
    'client_id' => env('KEYCLOAK_CLIENT_ID', 'lms-web'),
    'client_secret' => env('KEYCLOAK_CLIENT_SECRET', ''),
    'api_audience' => env('KEYCLOAK_API_AUDIENCE', 'lms-api'),
    'admin_realm' => env('KEYCLOAK_ADMIN_REALM', 'master'),
    'admin_client_id' => env('KEYCLOAK_ADMIN_CLIENT_ID', 'admin-cli'),
    'admin_username' => env('KEYCLOAK_ADMIN_USERNAME', 'admin'),
    'admin_password' => env('KEYCLOAK_ADMIN_PASSWORD', ''),
    'cache_ttl' => (int) env('KEYCLOAK_JWKS_CACHE_TTL', 3600),
    'leeway' => (int) env('KEYCLOAK_JWT_LEEWAY', 60),
    'http_timeout' => (int) env('KEYCLOAK_HTTP_TIMEOUT', 10),
    'verify_ssl' => (bool) env('KEYCLOAK_VERIFY_SSL', true),
];

