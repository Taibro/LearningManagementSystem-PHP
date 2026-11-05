# Architecture & Security Rules

## 1. Project Architecture (Multi-Tenant University LMS)
This repository is an enterprise-grade multi-tenant Learning Management System (LMS) designed for colleges and universities.

### Monorepo Layout
- **`lms-be`**: Backend built with Laravel 13 (PHP 8.3+) acting as OAuth2 Resource Server and PostgreSQL RLS enforcer.
- **`lms-fe`**: Frontend built with React 18 + Vite with 4 dedicated portal flows:
  - SaaS Super Admin: `/saas/*`
  - School Admin: `/:school/admin/*`
  - Lecturer: `/:school/lecturer/*`
  - Student: `/:school/student/*`
- **`lms-native`**: Cross-platform mobile client (React Native / Expo / Flutter).
- **`server-bootstrap`**: Infrastructure stack deployed via Docker Compose on Oracle Cloud Ubuntu VM (`140.245.54.161`):
  - PostgreSQL 16 (Port 5432)
  - Keycloak 26.5.4 (`auth-dev-api.duckdns.org`)
  - Nginx Reverse Proxy & SSL certificates (`lms-dev-api.duckdns.org`)

---

## 2. Authentication & Identity Provider (Keycloak OIDC)
- **Direct Access Grants Flow**:
  - The frontend NEVER redirects users to the Keycloak web login form.
  - The frontend sends user credentials (`username` / `email` + `password` + `school_id`) directly to `POST /api/auth/login`.
  - The backend communicates with Keycloak (`/realms/lms/protocol/openid-connect/token`) via Resource Owner Password Credentials Grant to retrieve access and refresh tokens.
- **Resilient Fallback Mode**:
  - If the remote Keycloak container has not yet imported or synchronized the latest realm users, the backend must verify credentials against `users.password_hash` in PostgreSQL and issue a compliant fallback OIDC JWT (HS256 signed with `app.key`) with deterministic `keycloak_id` claims.
  - Subsequent requests verify tokens through `KeycloakJwksService` supporting both Keycloak RS256 JWKS and local fallback HS256 tokens.

---

## 3. Database Multi-Tenancy & Row-Level Security (RLS)
- **Tenant Isolation by `school_id`**:
  - All operational academic tables (`users`, `students`, `teachers`, `classes`, `schedules`, `enrollments`, etc.) are partitioned logically by `school_id`.
- **Dual Database Connections**:
  - **`pgsql`**: Standard application connection utilizing `lms_app_role` (`NOBYPASSRLS`). Every request MUST set session context variables:
    - `SET LOCAL app.current_school_id = '<school_id>'`
    - `SET LOCAL app.current_user_id = '<user_id>'`
    - `SET LOCAL app.current_role = '<role>'`
  - **`pgsql_owner`**: Superuser/owner connection (`BYPASSRLS`). Strictly reserved for database migrations, initial seeding, system user lookup during authentication, and cross-tenant SaaS Admin statistics.

