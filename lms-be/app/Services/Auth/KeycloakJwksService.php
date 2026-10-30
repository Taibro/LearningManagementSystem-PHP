<?php

namespace App\Services\Auth;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class KeycloakJwksService
{
    /**
     * Decode and cryptographically verify a Keycloak RS256 JWT.
     */
    public function decodeToken(string $jwt): object
    {
        $parts = explode('.', $jwt);
        if (count($parts) !== 3) {
            throw new RuntimeException('Malformed JWT token.');
        }

        [$headB64, $bodyB64, $sigB64] = $parts;

        $header = json_decode($this->base64UrlDecode($headB64));
        $payload = json_decode($this->base64UrlDecode($bodyB64));
        $signature = $this->base64UrlDecode($sigB64);

        if (! is_object($header) || ! is_object($payload)) {
            throw new RuntimeException('Invalid JWT header or payload encoding.');
        }

        if (($header->alg ?? '') !== 'RS256') {
            throw new RuntimeException('Unsupported JWT algorithm. Expected RS256.');
        }

        $kid = $header->kid ?? null;
        $pem = $this->resolvePublicKeyPem($kid);

        $signingInput = $headB64.'.'.$bodyB64;
        $verified = openssl_verify($signingInput, $signature, $pem, OPENSSL_ALGO_SHA256);

        if ($verified !== 1) {
            // Clear cached JWKS once in case Keycloak rotated keys
            Cache::forget($this->getCacheKey());
            $pem = $this->resolvePublicKeyPem($kid);
            $verified = openssl_verify($signingInput, $signature, $pem, OPENSSL_ALGO_SHA256);

            if ($verified !== 1) {
                throw new RuntimeException('Invalid JWT signature.');
            }
        }

        $now = time();
        $leeway = (int) config('keycloak.leeway', 60);

        if (isset($payload->nbf) && $payload->nbf > ($now + $leeway)) {
            throw new RuntimeException('Token cannot be used yet (nbf).');
        }

        if (isset($payload->exp) && ($now - $leeway) >= $payload->exp) {
            throw new RuntimeException('Token has expired (exp).');
        }

        $expectedIssuer = config('keycloak.base_url').'/realms/'.config('keycloak.realm');
        if (! empty($payload->iss) && $payload->iss !== $expectedIssuer) {
            // Also allow matching realm path when internal/external hostname differs in Docker
            $realmSuffix = '/realms/'.config('keycloak.realm');
            if (! str_ends_with((string) $payload->iss, $realmSuffix)) {
                throw new RuntimeException('Invalid token issuer (iss).');
            }
        }

        $aud = $payload->aud ?? [];
        $audiences = is_array($aud) ? $aud : [$aud];
        $expectedAud = config('keycloak.api_audience', 'lms-api');
        $allowedAzp = [
            config('keycloak.client_id', 'lms-web'),
            'lms-web',
            'lms-mobile',
            'lms-api',
            'admin-cli',
            'account',
        ];

        if (
            ! in_array($expectedAud, $audiences, true) &&
            ! in_array($payload->azp ?? '', $allowedAzp, true)
        ) {
            throw new RuntimeException('Invalid token audience (aud / azp).');
        }

        return $payload;
    }

    /**
     * Resolve the PEM public key for the given key ID (kid) from Keycloak JWKS.
     */
    protected function resolvePublicKeyPem(?string $kid): string
    {
        $jwks = $this->getJwks();
        $keys = $jwks['keys'] ?? [];

        foreach ($keys as $key) {
            if ($kid !== null && ($key['kid'] ?? null) !== $kid) {
                continue;
            }

            if (! empty($key['x5c'][0])) {
                return "-----BEGIN CERTIFICATE-----\n"
                    .chunk_split($key['x5c'][0], 64, "\n")
                    ."-----END CERTIFICATE-----\n";
            }

            if (($key['kty'] ?? '') === 'RSA' && ! empty($key['n']) && ! empty($key['e'])) {
                return $this->jwkRsaToPem($key['n'], $key['e']);
            }
        }

        throw new RuntimeException('Matching public key (kid) not found in Keycloak JWKS.');
    }

    /**
     * Fetch and cache JWKS from Keycloak certs endpoint.
     *
     * @return array<string, mixed>
     */
    protected function getJwks(): array
    {
        return Cache::remember($this->getCacheKey(), config('keycloak.cache_ttl', 3600), function () {
            $certsUrl = config('keycloak.base_url').'/realms/'.config('keycloak.realm').'/protocol/openid-connect/certs';
            $response = Http::timeout((int) config('keycloak.http_timeout', 10))
                ->withOptions(['verify' => (bool) config('keycloak.verify_ssl', true)])
                ->get($certsUrl);

            if (! $response->successful()) {
                throw new RuntimeException('Unable to fetch JWKS from Keycloak: HTTP '.$response->status());
            }

            return $response->json();
        });
    }

    protected function getCacheKey(): string
    {
        return 'keycloak_jwks_'.config('keycloak.realm', 'lms');
    }

    /**
     * Convert RSA modulus (n) and exponent (e) from JWK Base64URL to PEM format.
     */
    protected function jwkRsaToPem(string $nB64, string $eB64): string
    {
        $modulus = $this->base64UrlDecode($nB64);
        $exponent = $this->base64UrlDecode($eB64);

        $modulus = ltrim($modulus, "\x00");
        if ((ord($modulus[0]) & 0x80) !== 0) {
            $modulus = "\x00".$modulus;
        }

        $exponent = ltrim($exponent, "\x00");
        if ((ord($exponent[0]) & 0x80) !== 0) {
            $exponent = "\x00".$exponent;
        }

        $modulusAsn1 = "\x02".$this->encodeDerLength(strlen($modulus)).$modulus;
        $exponentAsn1 = "\x02".$this->encodeDerLength(strlen($exponent)).$exponent;
        $rsaPublicKey = "\x30".$this->encodeDerLength(strlen($modulusAsn1.$exponentAsn1)).$modulusAsn1.$exponentAsn1;

        $bitString = "\x00".$rsaPublicKey;
        $bitStringAsn1 = "\x03".$this->encodeDerLength(strlen($bitString)).$bitString;

        // OID 1.2.840.113549.1.1.1 (rsaEncryption) + NULL
        $algorithmIdentifier = "\x30\x0d\x06\x09\x2a\x86\x48\x86\xf7\x0d\x01\x01\x01\x05\x00";
        $subjectPublicKeyInfo = "\x30"
            .$this->encodeDerLength(strlen($algorithmIdentifier.$bitStringAsn1))
            .$algorithmIdentifier
            .$bitStringAsn1;

        return "-----BEGIN PUBLIC KEY-----\n"
            .chunk_split(base64_encode($subjectPublicKeyInfo), 64, "\n")
            ."-----END PUBLIC KEY-----\n";
    }

    protected function encodeDerLength(int $length): string
    {
        if ($length <= 0x7F) {
            return chr($length);
        }

        $temp = ltrim(pack('N', $length), "\x00");

        return chr(0x80 | strlen($temp)).$temp;
    }

    public function base64UrlDecode(string $input): string
    {
        $remainder = strlen($input) % 4;
        if ($remainder) {
            $input .= str_repeat('=', 4 - $remainder);
        }

        return (string) base64_decode(strtr($input, '-_', '+/'));
    }
}

