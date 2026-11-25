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

    'cookie' => [
        'access_name' => env('AUTH_ACCESS_COOKIE', 'lms_access_token'),
        'refresh_name' => env('AUTH_REFRESH_COOKIE', 'lms_refresh_token'),
        'refresh_ttl_minutes' => (int) env('AUTH_REFRESH_COOKIE_TTL', 60 * 24 * 7),
        'domain' => env('AUTH_COOKIE_DOMAIN', env('SESSION_DOMAIN')),
        'secure' => env('AUTH_COOKIE_SECURE') !== null
            ? filter_var(env('AUTH_COOKIE_SECURE'), FILTER_VALIDATE_BOOLEAN)
            : (bool) env('SESSION_SECURE_COOKIE', false),
        'same_site' => env('AUTH_COOKIE_SAME_SITE', env('SESSION_SAME_SITE', 'lax')),
        'hide_tokens_in_body' => (bool) env('AUTH_HIDE_TOKENS_IN_BODY', false),
    ],
];

