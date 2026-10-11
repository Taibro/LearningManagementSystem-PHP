# 📁 Cấu Trúc Dự Án `lms-be` — Giải Thích Chi Tiết

> Dự án **LMS Backend** được xây dựng trên nền tảng **Laravel 13** (PHP 8.3+) kết hợp **Inertia.js + React + TypeScript** cho phần frontend, sử dụng **TailwindCSS 4** để styling. Dự án sử dụng kiến trúc **Laravel Starter Kit** với hỗ trợ **Teams** (nhóm/tổ chức), **Fortify** (xác thực nâng cao), và **Passkeys** (đăng nhập không mật khẩu).

---

## 📋 Mục Lục

- [1. Các File Gốc (Root Files)](#1-các-file-gốc-root-files)
- [2. Thư mục `app/`](#2-thư-mục-app)
- [3. Thư mục `bootstrap/`](#3-thư-mục-bootstrap)
- [4. Thư mục `config/`](#4-thư-mục-config)
- [5. Thư mục `database/`](#5-thư-mục-database)
- [6. Thư mục `public/`](#6-thư-mục-public)
- [7. Thư mục `resources/`](#7-thư-mục-resources)
- [8. Thư mục `routes/`](#8-thư-mục-routes)
- [9. Thư mục `storage/`](#9-thư-mục-storage)
- [10. Thư mục `tests/`](#10-thư-mục-tests)
- [11. Thư mục `vendor/` và `node_modules/`](#11-thư-mục-vendor-và-node_modules)
- [12. Các thư mục ẩn / cấu hình agent](#12-các-thư-mục-ẩn--cấu-hình-agent)

---

## 1. Các File Gốc (Root Files)

| File | Mô tả |
|------|--------|
| `.editorconfig` | Cấu hình thống nhất coding style (indent, encoding, EOL) cho tất cả editor/IDE. |
| `.env` | File biến môi trường **thực tế** (chứa key, database, mail config...). ⚠️ **Không commit lên Git**. |
| `.env.example` | File mẫu biến môi trường — hướng dẫn developer mới tạo file `.env` của riêng mình. |
| `.gitattributes` | Quy định cách Git xử lý file (line endings, diff behavior...). |
| `.gitignore` | Danh sách file/folder mà Git sẽ bỏ qua (vendor, node_modules, .env...). |
| `.npmrc` | Cấu hình npm (ví dụ: registry, save-exact...). |
| `AGENTS.md` | Tài liệu hướng dẫn cho các AI coding agent (Claude, Copilot...) hiểu cách làm việc với dự án. |
| `artisan` | File PHP CLI — entry point cho các lệnh Artisan (`php artisan serve`, `php artisan migrate`...). |
| `boost.json` | Cấu hình cho **Laravel Boost** — công cụ tối ưu hiệu suất development. |
| `components.json` | Cấu hình cho hệ thống UI components (shadcn/ui style). |
| `composer.json` | 📦 File quản lý dependency PHP (Laravel, Fortify, Inertia, Wayfinder...). Cũng chứa các script (`composer dev`, `composer test`...). |
| `composer.lock` | Lock file — đảm bảo mọi người cài đúng phiên bản dependency PHP. |
| `opencode.json` | Cấu hình cho OpenCode AI agent. |
| `package.json` | 📦 File quản lý dependency JavaScript/TypeScript (React, Inertia, Radix UI, TailwindCSS, Vite...). |
| `package-lock.json` | Lock file — đảm bảo mọi người cài đúng phiên bản dependency JS. |
| `phpstan.neon` | Cấu hình **PHPStan** — công cụ phân tích static code PHP để tìm lỗi tiềm ẩn. |
| `phpunit.xml` | Cấu hình **PHPUnit/Pest** — framework test cho PHP. |
| `pint.json` | Cấu hình **Laravel Pint** — công cụ auto-format code PHP theo chuẩn. |
| `pnpm-workspace.yaml` | Cấu hình workspace cho pnpm package manager. |
| `tsconfig.json` | Cấu hình **TypeScript** — quy định cách compile, paths, strict mode... |
| `update_sql.py` | Script Python tiện ích để cập nhật SQL. |
| `vite.config.ts` | ⚡ Cấu hình **Vite** — bundler/dev server cho frontend. Tích hợp Laravel plugin, Inertia, React, TailwindCSS, Wayfinder, React Compiler. |

---

## 2. Thư mục `app/`

> Đây là **trái tim** của ứng dụng — chứa toàn bộ business logic phía backend.

### 2.1. `app/Actions/` — Các Action Classes

Chứa các class xử lý **một hành động cụ thể** (Single Action pattern), tách biệt logic ra khỏi Controller.

#### `app/Actions/Fortify/` — Hành động xác thực (Fortify)

| File | Mô tả |
|------|--------|
| `CreateNewUser.php` | Logic tạo user mới khi đăng ký (validate, hash password, tạo record). |
| `ResetUserPassword.php` | Logic đặt lại mật khẩu cho user (validate mật khẩu mới, cập nhật DB). |

#### `app/Actions/Teams/` — Hành động liên quan Teams

| File | Mô tả |
|------|--------|
| `CreateTeam.php` | Logic tạo team mới (validate tên, gán owner). |

---

### 2.2. `app/Concerns/` — Traits tái sử dụng

| File | Mô tả |
|------|--------|
| `GeneratesUniqueTeamSlugs.php` | Trait tạo slug duy nhất cho team (ví dụ: `my-team`, `my-team-2`). |
| `HasTeams.php` | Trait thêm chức năng teams vào User model (quan hệ, chuyển team, kiểm tra quyền). |
| `PasswordValidationRules.php` | Trait định nghĩa rules validation cho mật khẩu (độ dài tối thiểu, ký tự đặc biệt...). |
| `ProfileValidationRules.php` | Trait định nghĩa rules validation cho thông tin profile. |

---

### 2.3. `app/Console/` — Artisan Commands

```
app/Console/
└── Commands/            ← (Thư mục rỗng — sẵn sàng để thêm custom Artisan commands)
```

---

### 2.4. `app/Data/` — Data Transfer Objects (DTO)

| File | Mô tả |
|------|--------|
| `TeamPermissions.php` | DTO chứa thông tin quyền hạn của team (permissions data). |
| `UserTeam.php` | DTO đại diện cho quan hệ user-team kèm dữ liệu bổ sung. |

---

### 2.5. `app/Enums/` — Enum Classes

| File | Mô tả |
|------|--------|
| `TeamPermission.php` | Enum định nghĩa các loại quyền trong team (ví dụ: `manage`, `view`...). |
| `TeamRole.php` | Enum định nghĩa các vai trò trong team (ví dụ: `owner`, `admin`, `member`...). |

---

### 2.6. `app/Http/` — Lớp HTTP (Controllers, Middleware, Requests, Responses)

#### `app/Http/Controllers/` — Xử lý request và trả response

| File | Mô tả |
|------|--------|
| `Controller.php` | Base controller — class cha cho tất cả controller. |
| `DashboardController.php` | Xử lý hiển thị trang Dashboard chính. |

##### `app/Http/Controllers/Settings/` — Controller cài đặt

| File | Mô tả |
|------|--------|
| `ProfileController.php` | Xử lý xem/sửa/xóa thông tin profile người dùng. |
| `SecurityController.php` | Xử lý cài đặt bảo mật (đổi mật khẩu, 2FA, passkeys). |

##### `app/Http/Controllers/Teams/` — Controller quản lý teams

| File | Mô tả |
|------|--------|
| `TeamController.php` | CRUD team (tạo, xem, sửa, xóa, chuyển team, rời team). |
| `TeamInvitationController.php` | Quản lý lời mời team (gửi, chấp nhận, từ chối, hủy). |
| `TeamMemberController.php` | Quản lý thành viên team (cập nhật role, xóa thành viên). |

#### `app/Http/Middleware/` — Middleware xử lý request

| File | Mô tả |
|------|--------|
| `EnsureTeamMembership.php` | Kiểm tra user có phải thành viên của team hiện tại không — chặn truy cập trái phép. |
| `HandleAppearance.php` | Xử lý cài đặt giao diện (dark/light mode) từ cookie. |
| `HandleInertiaRequests.php` | Chia sẻ dữ liệu chung (user, flash messages...) tới tất cả Inertia response. |
| `SetTeamUrlDefaults.php` | Tự động set giá trị mặc định cho parameter `{current_team}` trong URL. |

#### `app/Http/Requests/` — Form Request Validation

##### `app/Http/Requests/Settings/` — Validation cho Settings

| File | Mô tả |
|------|--------|
| `PasswordUpdateRequest.php` | Validate dữ liệu khi đổi mật khẩu. |
| `ProfileDeleteRequest.php` | Validate dữ liệu khi xóa tài khoản. |
| `ProfileUpdateRequest.php` | Validate dữ liệu khi cập nhật profile. |
| `TwoFactorAuthenticationRequest.php` | Validate dữ liệu cho xác thực 2 yếu tố. |

##### `app/Http/Requests/Teams/` — Validation cho Teams

| File | Mô tả |
|------|--------|
| `CreateTeamInvitationRequest.php` | Validate dữ liệu khi tạo lời mời team. |
| `DeleteTeamRequest.php` | Validate (và authorize) khi xóa team. |
| `RespondToTeamInvitationRequest.php` | Validate khi phản hồi lời mời (chấp nhận/từ chối). |
| `SaveTeamRequest.php` | Validate dữ liệu khi tạo/sửa team. |
| `UpdateTeamMemberRequest.php` | Validate khi cập nhật role thành viên. |

#### `app/Http/Responses/` — Custom Response Classes

| File | Mô tả |
|------|--------|
| `LoginResponse.php` | Tùy chỉnh response sau khi đăng nhập thành công (redirect về team dashboard). |
| `PasskeyLoginResponse.php` | Tùy chỉnh response sau khi đăng nhập bằng Passkey. |
| `RegisterResponse.php` | Tùy chỉnh response sau khi đăng ký thành công. |
| `TwoFactorLoginResponse.php` | Tùy chỉnh response sau khi xác thực 2FA thành công. |
| `VerifyEmailResponse.php` | Tùy chỉnh response sau khi xác minh email. |

##### `app/Http/Responses/Concerns/`

| File | Mô tả |
|------|--------|
| `RedirectsToCurrentTeam.php` | Trait xác định URL redirect về dashboard của team hiện tại. |

---

### 2.7. `app/Models/` — Eloquent Models (ORM)

| File | Mô tả |
|------|--------|
| `User.php` | Model người dùng — quan hệ với teams, 2FA, passkeys. |
| `Team.php` | Model team — thuộc tính, quan hệ members, invitations, owner. |
| `TeamInvitation.php` | Model lời mời tham gia team (email, role, expiration). |
| `Membership.php` | Model pivot — đại diện cho quan hệ nhiều-nhiều giữa User và Team. |

---

### 2.8. `app/Notifications/` — Thông báo

#### `app/Notifications/Teams/`

| File | Mô tả |
|------|--------|
| `TeamInvitation.php` | Notification gửi email mời tham gia team (bao gồm link chấp nhận). |

---

### 2.9. `app/Policies/` — Authorization Policies

| File | Mô tả |
|------|--------|
| `TeamPolicy.php` | Quy định quyền hạn cho các thao tác với Team (ai được xem, sửa, xóa, mời...). |

---

### 2.10. `app/Providers/` — Service Providers

| File | Mô tả |
|------|--------|
| `AppServiceProvider.php` | Provider chính — đăng ký bindings, cấu hình ứng dụng. |
| `FortifyServiceProvider.php` | Cấu hình Laravel Fortify — đăng ký các action cho login, register, 2FA, reset password... |

---

### 2.11. `app/Rules/` — Custom Validation Rules

| File | Mô tả |
|------|--------|
| `TeamName.php` | Rule validate tên team (ký tự hợp lệ, độ dài, không trùng slug reserved...). |
| `UniqueTeamInvitation.php` | Rule kiểm tra lời mời team không bị trùng lặp (cùng email + team). |
| `ValidTeamInvitation.php` | Rule validate lời mời team hợp lệ (chưa hết hạn, team tồn tại...). |

---

## 3. Thư mục `bootstrap/`

> Khởi tạo và cấu hình ứng dụng Laravel.

| File/Folder | Mô tả |
|-------------|--------|
| `app.php` | 📌 **Entry point chính** của ứng dụng — đăng ký routing, middleware stack, exception handling. |
| `providers.php` | Danh sách Service Providers cần đăng ký. |
| `cache/` | Chứa cache compiled (routes, config, services) — tự sinh bởi framework. |

---

## 4. Thư mục `config/`

> Chứa **toàn bộ file cấu hình** của ứng dụng. Mỗi file tương ứng với một khía cạnh của hệ thống.

| File | Mô tả |
|------|--------|
| `app.php` | Cấu hình chung: tên app, timezone, locale, encryption key, providers... |
| `auth.php` | Cấu hình xác thực: guards, providers, passwords reset. |
| `cache.php` | Cấu hình cache: driver (file, database, Redis, Memcached...). |
| `database.php` | Cấu hình database: connections (SQLite, MySQL, PostgreSQL), migrations. |
| `filesystems.php` | Cấu hình lưu trữ file: disks (local, public, S3...). |
| `fortify.php` | Cấu hình **Laravel Fortify**: bật/tắt features (registration, 2FA, email verification...). |
| `inertia.php` | Cấu hình **Inertia.js**: SSR settings, page resolution. |
| `logging.php` | Cấu hình logging: channels (stack, single, daily, Slack...). |
| `mail.php` | Cấu hình email: mailer (SMTP, SES, Mailgun...), from address. |
| `queue.php` | Cấu hình hàng đợi: connections (sync, database, Redis, SQS...). |
| `services.php` | Cấu hình third-party services (Mailgun, Postmark, AWS...). |
| `session.php` | Cấu hình session: driver, lifetime, encryption, cookie settings. |

---

## 5. Thư mục `database/`

> Quản lý **schema database**, dữ liệu test, và dữ liệu seed.

| File/Folder | Mô tả |
|-------------|--------|
| `database.sqlite` | File database SQLite (dùng cho development). |
| `.gitignore` | Bỏ qua file SQLite khi commit. |

### 5.1. `database/migrations/` — Migration Files

Quản lý schema database theo thứ tự thời gian (version control cho DB).

| File | Mô tả |
|------|--------|
| `0001_01_01_000000_create_users_table.php` | Tạo bảng `users`, `password_reset_tokens`, `sessions`. |
| `0001_01_01_000001_create_cache_table.php` | Tạo bảng `cache` và `cache_locks`. |
| `0001_01_01_000002_create_jobs_table.php` | Tạo bảng `jobs`, `job_batches`, `failed_jobs`. |
| `2024_01_01_000000_create_passkeys_table.php` | Tạo bảng `passkeys` cho đăng nhập không mật khẩu (WebAuthn). |
| `2025_08_14_170933_add_two_factor_columns_to_users_table.php` | Thêm cột 2FA vào bảng `users` (secret, recovery codes, confirmed_at). |
| `2026_01_27_000001_create_teams_table.php` | Tạo bảng `teams`, `team_user` (pivot), `team_invitations`. |
| `2026_01_27_000002_add_current_team_id_to_users_table.php` | Thêm cột `current_team_id` vào bảng `users`. |

### 5.2. `database/factories/` — Model Factories

Dùng để tạo dữ liệu giả cho testing.

| File | Mô tả |
|------|--------|
| `UserFactory.php` | Factory tạo User giả (name, email, password...). |
| `TeamFactory.php` | Factory tạo Team giả (name, slug, owner). |
| `TeamInvitationFactory.php` | Factory tạo TeamInvitation giả (email, role, team). |

### 5.3. `database/seeders/` — Database Seeders

| File | Mô tả |
|------|--------|
| `DatabaseSeeder.php` | Seeder chính — gọi các seeder con để tạo dữ liệu mẫu ban đầu. |

---

## 6. Thư mục `public/`

> Thư mục **public-facing** — web server trỏ vào đây. Chứa các file truy cập được từ trình duyệt.

| File/Folder | Mô tả |
|-------------|--------|
| `index.php` | 📌 **Entry point HTTP** — mọi request đều đi qua đây, khởi tạo Laravel app. |
| `.htaccess` | Cấu hình Apache (URL rewriting để mọi request vào `index.php`). |
| `favicon.ico` | Icon tab trình duyệt (dạng ICO). |
| `favicon.svg` | Icon tab trình duyệt (dạng SVG). |
| `apple-touch-icon.png` | Icon cho thiết bị Apple (khi bookmark). |
| `robots.txt` | Hướng dẫn cho search engine crawlers (index/noindex). |
| `build/` | 📦 Chứa assets đã được Vite build (JS, CSS compiled) — tự sinh khi chạy `npm run build`. |

---

## 7. Thư mục `resources/`

> Chứa **tất cả tài nguyên frontend** (views, JS, CSS) — chưa compile.

### 7.1. `resources/css/`

| File | Mô tả |
|------|--------|
| `app.css` | File CSS chính — import TailwindCSS, custom utilities, design tokens. |

### 7.2. `resources/views/`

| File | Mô tả |
|------|--------|
| `app.blade.php` | Template Blade gốc — HTML wrapper cho Inertia React app (chứa `<head>`, Vite assets, `@inertia` directive). |

### 7.3. `resources/js/` — Source code Frontend (React + TypeScript)

#### `resources/js/app.tsx`
> Entry point của React app — khởi tạo Inertia, render root component.

#### `resources/js/pages/` — Các trang (Pages)

Mỗi file tương ứng với **một route** trong ứng dụng (Inertia page component).

| File/Folder | Mô tả |
|-------------|--------|
| `welcome.tsx` | Trang chủ (landing page). |
| `dashboard.tsx` | Trang Dashboard sau khi đăng nhập. |

##### `resources/js/pages/auth/` — Trang xác thực

| File | Mô tả |
|------|--------|
| `login.tsx` | Trang đăng nhập (email + password, passkeys, 2FA). |
| `register.tsx` | Trang đăng ký tài khoản mới. |
| `forgot-password.tsx` | Trang quên mật khẩu (nhập email). |
| `reset-password.tsx` | Trang đặt lại mật khẩu (từ link email). |
| `confirm-password.tsx` | Trang xác nhận mật khẩu (trước thao tác nhạy cảm). |
| `two-factor-challenge.tsx` | Trang nhập mã 2FA (OTP hoặc recovery code). |
| `verify-email.tsx` | Trang xác minh email. |

##### `resources/js/pages/settings/` — Trang cài đặt

| File | Mô tả |
|------|--------|
| `profile.tsx` | Trang cài đặt thông tin cá nhân (tên, email, ảnh đại diện). |
| `security.tsx` | Trang cài đặt bảo mật (mật khẩu, 2FA, passkeys). |
| `appearance.tsx` | Trang cài đặt giao diện (dark/light mode). |

##### `resources/js/pages/teams/` — Trang quản lý teams

| File | Mô tả |
|------|--------|
| `index.tsx` | Trang danh sách teams của user. |
| `edit.tsx` | Trang chi tiết/chỉnh sửa team (thành viên, lời mời, settings). |

#### `resources/js/components/` — Các Component tái sử dụng

| File | Mô tả |
|------|--------|
| `app-content.tsx` | Wrapper cho nội dung chính của trang. |
| `app-header.tsx` | Header ứng dụng (navigation, user menu, team switcher). |
| `app-logo.tsx` | Component logo ứng dụng. |
| `app-logo-icon.tsx` | Component icon logo (nhỏ gọn). |
| `app-shell.tsx` | Shell layout bao ngoài toàn bộ ứng dụng. |
| `app-sidebar.tsx` | Sidebar navigation chính. |
| `app-sidebar-header.tsx` | Header của sidebar. |
| `alert-error.tsx` | Component hiển thị thông báo lỗi. |
| `appearance-tabs.tsx` | Tabs chuyển đổi giao diện (light/dark/system). |
| `breadcrumbs.tsx` | Component breadcrumb navigation. |
| `heading.tsx` | Component tiêu đề trang. |
| `input-error.tsx` | Component hiển thị lỗi validation cho input. |
| `nav-main.tsx` | Navigation chính (menu items). |
| `nav-footer.tsx` | Footer navigation. |
| `nav-user.tsx` | Navigation user (avatar + dropdown). |
| `password-input.tsx` | Input mật khẩu (có toggle show/hide). |
| `text-link.tsx` | Component link styled. |
| `user-info.tsx` | Component hiển thị thông tin user (avatar, name, email). |
| `user-menu-content.tsx` | Nội dung dropdown menu user. |

**Components liên quan Teams:**

| File | Mô tả |
|------|--------|
| `team-switcher.tsx` | Component chuyển đổi giữa các teams. |
| `team-invitation-alert.tsx` | Alert hiển thị lời mời team đang chờ. |
| `create-team-modal.tsx` | Modal tạo team mới. |
| `delete-team-modal.tsx` | Modal xác nhận xóa team. |
| `leave-team-modal.tsx` | Modal xác nhận rời team. |
| `invite-member-modal.tsx` | Modal mời thành viên mới vào team. |
| `cancel-invitation-modal.tsx` | Modal hủy lời mời. |
| `pending-invitations-modal.tsx` | Modal danh sách lời mời đang chờ. |
| `remove-member-modal.tsx` | Modal xác nhận xóa thành viên khỏi team. |

**Components liên quan 2FA / Passkeys:**

| File | Mô tả |
|------|--------|
| `manage-two-factor.tsx` | Component quản lý xác thực 2 yếu tố. |
| `two-factor-setup-modal.tsx` | Modal thiết lập 2FA (quét QR code). |
| `two-factor-recovery-codes.tsx` | Component hiển thị/tái tạo recovery codes. |
| `manage-passkeys.tsx` | Component quản lý passkeys. |
| `passkey-register.tsx` | Component đăng ký passkey mới. |
| `passkey-item.tsx` | Component hiển thị một passkey đã đăng ký. |
| `passkey-verify.tsx` | Component xác thực bằng passkey. |
| `delete-user.tsx` | Component xóa tài khoản user. |

##### `resources/js/components/ui/` — UI Primitives (shadcn/ui style)

Các component UI cơ bản, được xây dựng trên **Radix UI** primitives:

| File | Mô tả |
|------|--------|
| `alert.tsx` | Component thông báo (success, error, warning, info). |
| `avatar.tsx` | Component ảnh đại diện (hình tròn, fallback initials). |
| `badge.tsx` | Component badge/tag nhỏ. |
| `breadcrumb.tsx` | Component breadcrumb cơ bản. |
| `button.tsx` | Component nút bấm (nhiều variant: primary, secondary, ghost...). |
| `card.tsx` | Component thẻ (card container). |
| `checkbox.tsx` | Component checkbox. |
| `collapsible.tsx` | Component có thể thu gọn/mở rộng. |
| `dialog.tsx` | Component modal dialog. |
| `dropdown-menu.tsx` | Component menu dropdown. |
| `icon.tsx` | Component wrapper cho icons. |
| `input.tsx` | Component input text. |
| `input-otp.tsx` | Component nhập OTP (6 ô số). |
| `label.tsx` | Component label cho form field. |
| `navigation-menu.tsx` | Component menu navigation. |
| `placeholder-pattern.tsx` | Component placeholder pattern (loading state). |
| `select.tsx` | Component dropdown select. |
| `separator.tsx` | Component đường kẻ phân cách. |
| `sheet.tsx` | Component panel trượt từ cạnh màn hình. |
| `sidebar.tsx` | Component sidebar hoàn chỉnh (collapsible, responsive). |
| `skeleton.tsx` | Component skeleton loading animation. |
| `sonner.tsx` | Component toast notifications (dùng thư viện Sonner). |
| `spinner.tsx` | Component loading spinner. |
| `toggle.tsx` | Component toggle button. |
| `toggle-group.tsx` | Component nhóm toggle buttons. |
| `tooltip.tsx` | Component tooltip hover. |

#### `resources/js/layouts/` — Layout Components

| File | Mô tả |
|------|--------|
| `app-layout.tsx` | Layout chính cho phần ứng dụng (sau đăng nhập). |
| `auth-layout.tsx` | Layout cho các trang xác thực (login, register...). |

##### `resources/js/layouts/app/`

| File | Mô tả |
|------|--------|
| `app-header-layout.tsx` | Layout app với navigation ở header (top bar). |
| `app-sidebar-layout.tsx` | Layout app với sidebar navigation (bên trái). |

##### `resources/js/layouts/auth/`

| File | Mô tả |
|------|--------|
| `auth-card-layout.tsx` | Layout auth dạng thẻ card ở giữa trang. |
| `auth-simple-layout.tsx` | Layout auth đơn giản (form giữa trang). |
| `auth-split-layout.tsx` | Layout auth chia đôi màn hình (form + hình ảnh). |

##### `resources/js/layouts/settings/`

| File | Mô tả |
|------|--------|
| `layout.tsx` | Layout trang settings (sidebar tabs + content area). |

#### `resources/js/hooks/` — Custom React Hooks

| File | Mô tả |
|------|--------|
| `use-appearance.tsx` | Hook quản lý dark/light mode (đọc/ghi cookie). |
| `use-clipboard.ts` | Hook copy text vào clipboard. |
| `use-current-url.ts` | Hook lấy URL hiện tại (synced với Inertia). |
| `use-flash-toast.ts` | Hook hiển thị flash messages dạng toast. |
| `use-initials.tsx` | Hook tạo initials từ tên (ví dụ: "Nguyen Tai" → "NT"). |
| `use-mobile-navigation.ts` | Hook quản lý trạng thái mobile navigation (open/close). |
| `use-mobile.tsx` | Hook detect thiết bị mobile (responsive). |
| `use-two-factor-auth.ts` | Hook quản lý state 2FA (enable, confirm, disable). |

#### `resources/js/types/` — TypeScript Type Definitions

| File | Mô tả |
|------|--------|
| `index.ts` | Export chung các types. |
| `auth.ts` | Types liên quan xác thực (`User`, `Auth`, `Session`...). |
| `teams.ts` | Types liên quan teams (`Team`, `TeamMember`, `TeamInvitation`...). |
| `navigation.ts` | Types cho navigation items (`NavItem`, `NavGroup`...). |
| `ui.ts` | Types cho UI components (`BreadcrumbItem`, `SharedData`...). |
| `global.d.ts` | Type declarations toàn cục. |
| `vite-env.d.ts` | Type declarations cho Vite environment. |

#### `resources/js/lib/` — Utility Functions

| File | Mô tả |
|------|--------|
| `utils.ts` | Hàm tiện ích (`cn()` — merge className với clsx + tailwind-merge). |

#### `resources/js/actions/` — Generated Action Helpers

Chứa các helper được tự động sinh bởi framework, tổ chức theo namespace:

| Folder | Mô tả |
|--------|--------|
| `App/` | Helpers cho các controller của ứng dụng. |
| `Illuminate/` | Helpers cho các controller của Laravel framework. |
| `Inertia/` | Helpers cho Inertia.js actions. |
| `Laravel/` | Helpers cho các Laravel packages (Fortify...). |

#### `resources/js/routes/` — Generated Route Helpers

| File | Mô tả |
|------|--------|
| `index.ts` | Route helpers được tự sinh — giúp gọi routes type-safe từ frontend. |

#### `resources/js/wayfinder/` — Wayfinder Generated Code

Chứa code tự sinh bởi **Laravel Wayfinder** — cung cấp type-safe routing giữa backend Laravel và frontend React.

---

## 8. Thư mục `routes/`

> Định nghĩa **tất cả HTTP routes** của ứng dụng.

| File | Mô tả |
|------|--------|
| `web.php` | 📌 **Routes chính** — trang chủ, dashboard (scoped theo team), xử lý lời mời team. |
| `settings.php` | Routes cho phần Settings — profile, security, password, appearance, teams CRUD, members, invitations, passkey endpoints. |
| `console.php` | Đăng ký custom Artisan commands chạy từ CLI. |

---

## 9. Thư mục `storage/`

> Chứa **dữ liệu sinh ra bởi ứng dụng** (logs, cache, sessions, uploads...).

| Folder | Mô tả |
|--------|--------|
| `app/` | File do ứng dụng sinh (uploads, generated files...). |
| `framework/` | Cache, sessions, views compiled bởi Laravel framework. |
| `logs/` | File log ứng dụng (`laravel.log`). |
| `inertia-devtools/` | Dữ liệu của Inertia DevTools (development only). |

---

## 10. Thư mục `tests/`

> Chứa **toàn bộ test code** — sử dụng **Pest PHP** (wrapper trên PHPUnit).

| File | Mô tả |
|------|--------|
| `TestCase.php` | Base test class — mọi test đều extend từ đây. |
| `Pest.php` | Cấu hình Pest — đăng ký base test class, helper methods. |

### 10.1. `tests/Feature/` — Integration/Feature Tests

| File/Folder | Mô tả |
|-------------|--------|
| `ExampleTest.php` | Test mẫu — kiểm tra trang chủ trả về 200. |
| `DashboardTest.php` | Test dashboard (redirect chưa login, hiển thị khi đã login). |

##### `tests/Feature/Auth/` — Tests xác thực

| File | Mô tả |
|------|--------|
| `AuthenticationTest.php` | Test đăng nhập (thành công, sai mật khẩu, throttle...). |
| `RegistrationTest.php` | Test đăng ký (tạo user, validation, tự tạo team...). |
| `EmailVerificationTest.php` | Test xác minh email. |
| `PasswordResetTest.php` | Test đặt lại mật khẩu. |
| `PasswordConfirmationTest.php` | Test xác nhận mật khẩu. |
| `TwoFactorChallengeTest.php` | Test xác thực 2FA. |
| `VerificationNotificationTest.php` | Test gửi notification xác minh email. |

##### `tests/Feature/Settings/` — Tests cài đặt

| File | Mô tả |
|------|--------|
| `ProfileUpdateTest.php` | Test cập nhật profile (name, email, delete account...). |
| `SecurityTest.php` | Test cài đặt bảo mật (đổi password). |

##### `tests/Feature/Teams/` — Tests teams

| File | Mô tả |
|------|--------|
| `TeamTest.php` | Test CRUD team (tạo, sửa, xóa, chuyển team). |
| `TeamMemberTest.php` | Test quản lý thành viên (cập nhật role, xóa member). |
| `TeamInvitationTest.php` | Test lời mời (gửi, chấp nhận, từ chối, hủy). |
| `PruneExpiredTeamInvitationsTest.php` | Test tự động xóa lời mời hết hạn. |

### 10.2. `tests/Unit/` — Unit Tests

| File | Mô tả |
|------|--------|
| `ExampleTest.php` | Test mẫu unit (test logic đơn giản, không cần database). |

---

## 11. Thư mục `vendor/` và `node_modules/`

| Folder | Mô tả |
|--------|--------|
| `vendor/` | 📦 Chứa **toàn bộ PHP dependencies** được cài qua Composer. ⚠️ **Không chỉnh sửa trực tiếp**. Không commit lên Git. |
| `node_modules/` | 📦 Chứa **toàn bộ JS/TS dependencies** được cài qua npm/pnpm. ⚠️ **Không chỉnh sửa trực tiếp**. Không commit lên Git. |

---

## 12. Các Thư Mục Ẩn / Cấu Hình Agent

| Folder | Mô tả |
|--------|--------|
| `.agents/` | Cấu hình cho AI coding agents (rules, skills). |
| `.github/` | Cấu hình GitHub (Actions CI/CD, issue templates, PR templates...). |
| `.junie/` | Cấu hình cho JetBrains Junie AI agent. |

---

## 🏗️ Tổng Quan Kiến Trúc

```
┌─────────────────────────────────────────────────────────┐
│                     TRÌNH DUYỆT                         │
│               (React + TypeScript + Inertia)            │
└────────────────────────┬────────────────────────────────┘
                         │ Inertia Protocol (XHR/JSON)
┌────────────────────────▼────────────────────────────────┐
│                   LARAVEL BACKEND                        │
│  ┌──────────┐  ┌────────────┐  ┌──────────────────┐     │
│  │  Routes  │→ │ Middleware │→ │   Controllers    │     │
│  └──────────┘  └────────────┘  └───────┬──────────┘     │
│                                        │                 │
│  ┌──────────┐  ┌────────────┐  ┌───────▼──────────┐     │
│  │ Requests │  │  Actions   │  │  Models (ORM)    │     │
│  │(Validate)│  │ (Business) │  │  Policies (Auth) │     │
│  └──────────┘  └────────────┘  └───────┬──────────┘     │
│                                        │                 │
│                              ┌─────────▼─────────┐      │
│                              │    DATABASE        │      │
│                              │  (SQLite/Postgres) │      │
│                              └───────────────────┘      │
└─────────────────────────────────────────────────────────┘
```

---

## 🚀 Lệnh Thường Dùng

| Lệnh | Mô tả |
|-------|--------|
| `composer dev` | Chạy đồng thời server PHP + queue worker + Vite dev server. |
| `composer setup` | Cài đặt toàn bộ dependencies + migrate + build. |
| `composer test` | Chạy lint + static analysis + tests. |
| `php artisan migrate` | Chạy database migrations. |
| `php artisan db:seed` | Chạy database seeders. |
| `npm run dev` | Chạy Vite dev server (hot reload frontend). |
| `npm run build` | Build production assets. |
| `npm run check` | Lint check frontend code. |
| `npm run types:check` | Kiểm tra TypeScript types. |
