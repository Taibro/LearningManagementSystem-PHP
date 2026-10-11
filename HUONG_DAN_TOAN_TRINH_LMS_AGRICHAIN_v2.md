# HƯỚNG DẪN TOÀN TRÌNH (v2 — đã rà soát & sửa lỗi): 2 REPO (LMS + AGRICHAIN) — CI/CD + ANSIBLE + DOCKER + NETLIFY + DUCKDNS + FLUTTER

> **Về bản v2.** Sửa các lỗi chặn và lỗ hổng của bản gốc (xem **Phụ lục A**) và tối ưu code triển khai.
>
> **Đã chạy thử trong sandbox:** parse YAML toàn bộ file; `ansible-playbook --syntax-check` cho 3 playbook; render template bằng Ansible thật + `nginx -t` (nginx 1.24, cả chế độ HTTP lẫn HTTPS); đối chiếu mọi biến `${...}` của Compose với `.env`; `bash -n` cho mọi step `run` trong workflow; kiểm tra biểu thức Jinja và regex `APP_KEY`; kiểm tra tên tham số các module `iptables`, `cron`, `apt`, `shell`.
>
> **Chưa chạy thử được** (sandbox không có Docker / VM Oracle): build image, `docker compose up`, certbot thật, iptables thật. Ở lần deploy đầu tiên hãy theo dõi log theo Phần 6.

---

## PHẦN 0: KIẾN TRÚC TỔNG THỂ

```text
┌─ REPO lms ────────────────────────────────────────────────────────┐
│ backend/  ──GH Actions──► rsync + Ansible ──► Oracle server       │
│                           (Docker: lms_db + lms_backend + lms_web)│
│                           https://lms-api-vnic.duckdns.org (:8081)│
│ frontend/ ──GH Actions──► Netlify  https://lms-vnic.netlify.app   │
│ mobile/   ──GH Actions──► artifact APK (không deploy)             │
└───────────────────────────────────────────────────────────────────┘
┌─ REPO agrichain ──────────────────────────────────────────────────┐
│ backend/  ──► Oracle (mysql, mongo, cassandra, neo4j, redis,      │
│             mosquitto + agri_backend + agri_web) :8082            │
│             https://agri-api-vnic.duckdns.org                     │
│ frontend/ ──► Netlify  https://agri-vnic.netlify.app              │
│ mobile/   ──► artifact APK                                        │
└───────────────────────────────────────────────────────────────────┘
┌─ REPO server-bootstrap (chạy 1 lần — chạy lại vẫn an toàn) ───────┐
│ Docker + Nginx (TLS) + Certbot + Keycloak chung                   │
│ https://auth-vnic.duckdns.org (127.0.0.1:8080) + 1 cert SAN       │
└───────────────────────────────────────────────────────────────────┘
```

### Bảng phân bổ Domain & Port

| Thành phần | Domain | Port (chỉ bind `127.0.0.1`, Nginx trên host proxy vào) |
| :--- | :--- | :--- |
| **Keycloak (chung)** | `auth-vnic.duckdns.org` | `127.0.0.1:8080` (health: `127.0.0.1:9000`) |
| **LMS backend** | `lms-api-vnic.duckdns.org` | `127.0.0.1:8081` |
| **Agrichain backend** | `agri-api-vnic.duckdns.org` | `127.0.0.1:8082` |
| **LMS frontend** | `lms-vnic.netlify.app` | Netlify CDN |
| **Agrichain frontend** | `agri-vnic.netlify.app` | Netlify CDN |

Từ Internet chỉ có **22 / 80 / 443** đi vào được VM. Không service nào khác được publish ra `0.0.0.0`.

---

## PHẦN 1: CHUẨN BỊ NGOÀI CODE

### 1.1. Đăng ký DuckDNS (3 domain, ~5 phút)
1. Mở [https://www.duckdns.org](https://www.duckdns.org) → đăng nhập bằng GitHub.
2. Lần lượt tạo 3 domain:
   - `lms-api-vnic`
   - `agri-api-vnic`
   - `auth-vnic`
3. Mỗi domain đặt `current ip` = `140.245.54.161` → bấm **Save**.
4. Ghi lại **token** (góc trên cùng trang). Token chỉ cần nếu sau này IP đổi và bạn muốn cron tự cập nhật; với IP cố định thì không dùng tới.
5. Kiểm tra từ máy local:
   ```bash
   nslookup lms-api-vnic.duckdns.org 8.8.8.8
   nslookup agri-api-vnic.duckdns.org 8.8.8.8
   nslookup auth-vnic.duckdns.org 8.8.8.8
   ```
   > Cả 3 phải trả về đúng IP `140.245.54.161`.

### 1.2. Oracle Cloud
- Mở cổng **TCP 443**: **Console** → **Networking** → **VCN** → **Security Lists** → **Add ingress rule** (Port `443`, CIDR `0.0.0.0/0`). Cổng 80 và 22 đã có.
- Image Ubuntu của OCI còn có **luật iptables ngay trên VM** chặn mọi cổng ngoài SSH — mở Security List là *chưa đủ*. Playbook ở Phần 2 đã mở 80/443 ở tầng này (task `Mở cổng 80/443 trong iptables`).
- Nên gán **Reserved Public IP** cho VM: IP ephemeral gắn với vòng đời VM, xoá/tạo lại VM là mất IP và phải sửa lại cả 3 domain DuckDNS.

### 1.3. Netlify (2 site riêng biệt)
Thực hiện 2 lần (một cho `lms`, một cho `agrichain`):
1. Truy cập [https://app.netlify.com](https://app.netlify.com) → đăng nhập GitHub.
2. **Add new site** → **Deploy manually** (kéo thả thư mục trống bất kỳ hoặc bỏ qua) → site được tạo.
3. **Site settings** → **Change site name** → `lms-vnic` (và `agri-vnic` cho repo kia) → URL trở thành:
   - `https://lms-vnic.netlify.app`
   - `https://agri-vnic.netlify.app`
4. **Site settings** → **General** → **Site ID** → copy.
5. **User settings** → **Applications** → **Personal access tokens** → **New access token** → copy (chỉ hiện 1 lần).
6. Vào repo GitHub tương ứng → **Settings** → **Secrets and variables** → đặt Secrets/Variables theo **bảng 7.2** (danh sách đầy đủ nằm ở đó, không liệt kê lại ở đây để khỏi lệch nhau).

### 1.4. Sinh secret (làm một lần, rồi lưu vào GitHub Secrets)
```bash
# Mật khẩu (DB, Redis, Mongo, MQTT, Keycloak): chỉ gồm [0-9a-f] nên an toàn với .env / Compose / shell
openssl rand -hex 24

# APP_KEY của Laravel (mỗi app một key; tạo MỘT LẦN rồi giữ nguyên mãi)
echo "base64:$(openssl rand -base64 32)"
```
> Đổi `APP_KEY` = không giải mã được dữ liệu đã mã hoá và đăng xuất toàn bộ phiên. Mật khẩu DB chỉ có tác dụng ở **lần khởi tạo volume đầu tiên** (xem Phần 7).

### 1.5. SSH deploy key (riêng cho CI)
```bash
ssh-keygen -t ed25519 -C "gha-deploy" -f gha_deploy -N ""
# gắn public key vào server (dùng khóa Oracle hiện tại để đăng nhập):
ssh -i <khoa-oracle-hien-tai> ubuntu@140.245.54.161 'cat >> ~/.ssh/authorized_keys' < gha_deploy.pub
# Secret SSH_PRIVATE_KEY = TOÀN BỘ nội dung file gha_deploy (gồm dòng BEGIN/END và xuống dòng cuối)
```
Workflow tự chạy `ssh-keyscan` để ghi host key vào `known_hosts` (TOFU). Muốn chặt hơn: chạy `ssh-keyscan -H 140.245.54.161` một lần ở máy bạn, lưu kết quả vào Variable `SSH_KNOWN_HOSTS` và thay bước keyscan bằng `echo "$SSH_KNOWN_HOSTS" >> ~/.ssh/known_hosts`.

---

## PHẦN 2: REPO server-bootstrap (chạy bằng nút Run workflow — chạy lại an toàn)

### Cấu trúc thư mục
```text
server-bootstrap/
├── bootstrap.yml
├── templates/
│   ├── health.conf.j2
│   ├── vhost.conf.j2
│   ├── keycloak.env.j2
│   └── keycloak-compose.yml.j2
└── .github/
    └── workflows/
        └── bootstrap.yml
```
(Không còn `inventory.ini`: IP lấy từ Variable `SERVER_IP`, chỉ khai báo một nơi.)

### `bootstrap.yml`
```yaml
---
- name: Bootstrap server (Docker + Nginx + Certbot + Keycloak)
  hosts: all
  become: true
  vars:
    deploy_user: ubuntu
    domains:
      - { domain: "lms-api-vnic.duckdns.org",  port: 8081 }
      - { domain: "agri-api-vnic.duckdns.org", port: 8082 }
      - { domain: "auth-vnic.duckdns.org",     port: 8080 }
    auth_domain: "auth-vnic.duckdns.org"
    cert_name: "{{ domains[0].domain }}"        # certbot đặt tên lineage theo domain đầu tiên
    cert_domain_args: "{{ domains | map(attribute='domain') | map('regex_replace', '^', '-d ') | join(' ') }}"
    kc_admin_user: "admin"
    # Secret đọc từ biến môi trường của runner => không lộ trên command line, không cần -e
    cert_email: "{{ lookup('env', 'CERT_EMAIL') }}"
    kc_db_password: "{{ lookup('env', 'KC_DB_PASSWORD') }}"
    kc_admin_password: "{{ lookup('env', 'KC_ADMIN_PASSWORD') }}"

  pre_tasks:
    - name: Kiểm tra biến bắt buộc
      ansible.builtin.assert:
        that:
          - cert_email | length > 0
          - kc_db_password | length >= 12
          - kc_admin_password | length >= 12
        fail_msg: "Thiếu CERT_EMAIL (Variable) hoặc KC_DB_PASSWORD / KC_ADMIN_PASSWORD (Secret, tối thiểu 12 ký tự)"

  tasks:
    - name: Install base packages + nginx + certbot
      ansible.builtin.apt:
        name: [ca-certificates, curl, gnupg, rsync, nginx, certbot]
        state: present
        update_cache: true
        lock_timeout: 300            # unattended-upgrades hay giữ lock dpkg khi VM mới boot

    - name: Install Docker
      ansible.builtin.shell:
        cmd: curl -fsSL https://get.docker.com | sh
        creates: /usr/bin/docker

    - name: Docker log rotation (tránh đầy ổ đĩa)
      ansible.builtin.copy:
        dest: /etc/docker/daemon.json
        content: |
          {"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}
        mode: "0644"
      notify: restart docker

    - name: Enable services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: started
        enabled: true
      loop: [docker, nginx]

    - name: Áp dụng cấu hình Docker ngay
      ansible.builtin.meta: flush_handlers

    # Image Ubuntu của OCI có sẵn luật iptables chặn mọi cổng ngoài SSH:
    # mở Security List là CHƯA ĐỦ. (Bỏ 2 task này nếu VM của bạn dùng ufw/không có luật REJECT.)
    - name: Mở cổng 80/443 trong iptables
      ansible.builtin.iptables:
        chain: INPUT
        protocol: tcp
        destination_port: "{{ item }}"
        ctstate: [NEW]
        jump: ACCEPT
        action: insert
        rule_num: "6"
        comment: "allow tcp/{{ item }}"
      loop: ["80", "443"]
      register: fw

    - name: Lưu luật iptables
      ansible.builtin.command: netfilter-persistent save
      when: fw.changed

    - name: Gỡ site mặc định của nginx (đang giữ default_server trên :80)
      ansible.builtin.file:
        path: /etc/nginx/sites-enabled/default
        state: absent
      notify: reload nginx

    - name: Create dirs
      ansible.builtin.file:
        path: "{{ item.path }}"
        state: directory
        owner: "{{ item.owner | default('root') }}"
        mode: "0755"
      loop:
        - { path: /opt/keycloak }
        - { path: /opt/lms,       owner: "{{ deploy_user }}" }
        - { path: /opt/agrichain, owner: "{{ deploy_user }}" }
        - { path: /var/www/certbot }
      loop_control: { label: "{{ item.path }}" }

    - name: Deploy default health vhost
      ansible.builtin.template:
        src: health.conf.j2
        dest: /etc/nginx/sites-available/00-health
        mode: "0644"
      notify: reload nginx

    - name: Cert đã có chưa?
      ansible.builtin.stat:
        path: "/etc/letsencrypt/live/{{ cert_name }}/fullchain.pem"
      register: cert

    - name: Deploy proxy vhosts (đã có cert => HTTPS; chưa có => chỉ HTTP để xin cert)
      ansible.builtin.template:
        src: vhost.conf.j2
        dest: "/etc/nginx/sites-available/{{ item.domain }}"
        mode: "0644"
      vars:
        tls: "{{ cert.stat.exists }}"
      loop: "{{ domains }}"
      loop_control: { label: "{{ item.domain }}" }
      notify: reload nginx

    - name: Enable sites
      ansible.builtin.file:
        src: "/etc/nginx/sites-available/{{ item }}"
        dest: "/etc/nginx/sites-enabled/{{ item }}"
        state: link
      loop: "{{ ['00-health'] + (domains | map(attribute='domain') | list) }}"
      notify: reload nginx

    - name: Reload nginx (để challenge HTTP-01 chạy được)
      ansible.builtin.meta: flush_handlers

    - name: Deploy keycloak .env + compose
      ansible.builtin.template:
        src: "{{ item.src }}"
        dest: "/opt/keycloak/{{ item.dest }}"
        mode: "{{ item.mode }}"
      loop:
        - { src: keycloak.env.j2,         dest: .env,               mode: "0600" }
        - { src: keycloak-compose.yml.j2, dest: docker-compose.yml, mode: "0644" }
      loop_control: { label: "{{ item.dest }}" }

    - name: Start keycloak
      ansible.builtin.command: docker compose up -d
      args: { chdir: /opt/keycloak }
      register: kc_up
      changed_when: "'Started' in kc_up.stderr or 'Created' in kc_up.stderr or 'Recreated' in kc_up.stderr"

    - name: Wait keycloak ready (health nằm ở management port 9000)
      ansible.builtin.uri:
        url: http://127.0.0.1:9000/health/ready
        status_code: 200
      register: kc
      until: kc.status == 200
      retries: 60
      delay: 5

    - name: Issue Let's Encrypt SAN certificate (webroot, chỉ 1 lần)
      ansible.builtin.command: >
        certbot certonly --webroot -w /var/www/certbot -n --agree-tos
        -m {{ cert_email }} --cert-name {{ cert_name }}
        --deploy-hook "systemctl reload nginx"
        {{ cert_domain_args }}
      args:
        creates: "/etc/letsencrypt/live/{{ cert_name }}/fullchain.pem"

    - name: Deploy vhosts bản HTTPS (sau khi chắc chắn có cert)
      ansible.builtin.template:
        src: vhost.conf.j2
        dest: "/etc/nginx/sites-available/{{ item.domain }}"
        mode: "0644"
      vars:
        tls: true
      loop: "{{ domains }}"
      loop_control: { label: "{{ item.domain }}" }
      notify: reload nginx

    - name: certbot.timer (tự gia hạn)
      ansible.builtin.systemd:
        name: certbot.timer
        enabled: true
        state: started

  handlers:
    - name: reload nginx
      ansible.builtin.systemd: { name: nginx, state: reloaded }
    - name: restart docker
      ansible.builtin.systemd: { name: docker, state: restarted }
```

### `templates/health.conf.j2`
```nginx
server {
    listen 80 default_server;
    server_name _;
    location = /health { default_type text/plain; return 200 "OK"; }
    location / { return 404; }
}
```

### `templates/vhost.conf.j2`
```nginx
{# tls=false: chỉ HTTP (giai đoạn xin cert). tls=true: HTTP -> HTTPS, proxy chạy ở khối 443. #}
server {
    listen 80;
    server_name {{ item.domain }};

    location /.well-known/acme-challenge/ { root /var/www/certbot; }
{% if tls | bool %}

    location / { return 301 https://$host$request_uri; }
}

server {
    listen 443 ssl http2;
    server_name {{ item.domain }};

    ssl_certificate     /etc/letsencrypt/live/{{ cert_name }}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{{ cert_name }}/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 1d;
    ssl_session_tickets off;
    add_header Strict-Transport-Security "max-age=31536000" always;
{% endif %}

    location / {
        proxy_pass http://127.0.0.1:{{ item.port }};
        proxy_http_version 1.1;
        proxy_set_header Host              $host;
        proxy_set_header X-Real-IP         $remote_addr;
        proxy_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Forwarded-Host  $host;
        proxy_set_header X-Forwarded-Port  $server_port;

        client_max_body_size 20m;          # mặc định 1m => upload ảnh/file bị 413

        # Keycloak trả header/cookie lớn: thiếu 3 dòng này sẽ gặp 502 "upstream sent too big header"
        proxy_buffer_size       128k;
        proxy_buffers           4 256k;
        proxy_busy_buffers_size 256k;
    }
}
```

### `templates/keycloak.env.j2`
```env
KC_DB_PASSWORD={{ kc_db_password }}
KC_ADMIN_USER={{ kc_admin_user }}
KC_ADMIN_PASSWORD={{ kc_admin_password }}
KC_HOSTNAME=https://{{ auth_domain }}
```

### `templates/keycloak-compose.yml.j2`
```yaml
services:
  keycloak_db:
    image: postgres:16-alpine
    container_name: keycloak_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: keycloak
      POSTGRES_USER: keycloak
      POSTGRES_PASSWORD: ${KC_DB_PASSWORD}
    volumes: [kc_pg_data:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U keycloak -d keycloak"]
      interval: 5s
      timeout: 3s
      retries: 20
    mem_limit: 512m
    networks: [kc_net]

  keycloak:
    image: quay.io/keycloak/keycloak:26.5.4   # ghim bản vá cụ thể; kiểm tra bản mới nhất trước khi deploy
    container_name: keycloak_server
    restart: unless-stopped
    command: ["start"]
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak_db:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: ${KC_DB_PASSWORD}
      KC_BOOTSTRAP_ADMIN_USERNAME: ${KC_ADMIN_USER}      # thay cho KEYCLOAK_ADMIN (đã deprecated từ 26)
      KC_BOOTSTRAP_ADMIN_PASSWORD: ${KC_ADMIN_PASSWORD}
      KC_HOSTNAME: ${KC_HOSTNAME}
      KC_PROXY_HEADERS: xforwarded
      KC_HTTP_ENABLED: "true"
      KC_HEALTH_ENABLED: "true"                          # bắt buộc, mặc định KHÔNG có endpoint health
    ports:
      - "127.0.0.1:8080:8080"                            # chỉ nginx trên host được gọi
      - "127.0.0.1:9000:9000"                            # management/health
    depends_on:
      keycloak_db: { condition: service_healthy }
    mem_limit: 1500m
    networks: [kc_net]

volumes:
  kc_pg_data:
networks:
  kc_net:
```

### `.github/workflows/bootstrap.yml` (chạy tay bằng nút Run workflow)
```yaml
name: Bootstrap Server
on: [workflow_dispatch]
permissions:
  contents: read
jobs:
  bootstrap:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    env:
      SERVER_IP: ${{ vars.SERVER_IP }}
    steps:
      - uses: actions/checkout@v4

      - name: Prepare SSH (key + known_hosts)
        env:
          SSH_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        run: |
          : "${SERVER_IP:?Chưa đặt Variable SERVER_IP}"
          install -m 700 -d ~/.ssh
          printf '%s\n' "$SSH_KEY" > ~/.ssh/id_deploy
          chmod 600 ~/.ssh/id_deploy
          ssh-keyscan -H "$SERVER_IP" >> ~/.ssh/known_hosts

      - name: Install ansible-core
        run: pip install --quiet ansible-core

      - name: Run bootstrap
        env:
          CERT_EMAIL: ${{ vars.CERT_EMAIL }}
          KC_DB_PASSWORD: ${{ secrets.KC_DB_PASSWORD }}
          KC_ADMIN_PASSWORD: ${{ secrets.KC_ADMIN_PASSWORD }}
        run: >
          ansible-playbook -i "${SERVER_IP},"
          -u ubuntu --private-key ~/.ssh/id_deploy bootstrap.yml
```

### Vì sao sửa như vậy
- **Gỡ `sites-enabled/default`.** Gói nginx của Ubuntu tạo sẵn site này với `listen 80 default_server`; trùng với `00-health` thì `nginx -t` báo `a duplicate default server for 0.0.0.0:80` (đã tái hiện trong sandbox), handler `reload nginx` fail và cả playbook dừng.
- **TLS nằm trong template, cert xin bằng `certonly --webroot`.** Bản gốc để `certbot --nginx` sửa thẳng file vhost; chạy lại playbook thì template ghi đè mất cấu hình TLS, còn `creates:` chặn certbot chạy lại ⇒ mất HTTPS. Bản v2: certbot không đụng vào cấu hình nginx; vhost HTTPS do template tạo; gia hạn do `certbot.timer`, `--deploy-hook` tự reload nginx.
- **Chờ Keycloak ở cổng 9000 và bật `KC_HEALTH_ENABLED`.** Trong Keycloak 26 (theo tài liệu chính thức) endpoint health nằm ở *management port* (9000) và mặc định **không bật**; bản gốc gọi `:8080/health/ready` sẽ chờ hết 5 phút rồi fail.
- **`KC_BOOTSTRAP_ADMIN_*`** thay cho `KEYCLOAK_ADMIN*` (deprecated từ Keycloak 26; có tài liệu báo bản 26.4 không còn đọc tên cũ).
- **Bind `127.0.0.1`** cho Keycloak (bản gốc publish `8080:8080` ra mọi interface).
- **Bỏ biến tự tham chiếu** `kc_db_password: "{{ kc_db_password }}"` (chạy được nhờ `-e`, bỏ `-e` là lỗi `Recursive loop detected`). Secret nay đọc từ biến môi trường của runner, không nằm trên command line.
- **Tạo sẵn `/opt/lms`, `/opt/agrichain` thuộc user `ubuntu`** để bước rsync của workflow không bị `Permission denied`.
- **Log rotation Docker** (mặc định log json không giới hạn → đầy đĩa), **`lock_timeout` cho apt** (unattended-upgrades hay giữ lock lúc VM mới boot).
- `get.docker.com` tiện cho lab; môi trường nghiêm túc nên cài Docker từ apt repo chính thức và ghim phiên bản.

---

## PHẦN 3: REPO lms (đầy đủ)

### Cấu trúc thư mục
```text
lms/
├── backend/
│   ├── Dockerfile
│   ├── Dockerfile.dockerignore
│   ├── docker-compose.yml
│   └── docker/
│       └── nginx.conf
├── frontend/            # React Vite + public/_redirects + devDependency netlify-cli
├── mobile/              # Flutter
├── deploy/
│   ├── lms.yml
│   └── templates/
│       └── lms.env.j2
└── .github/
    └── workflows/
        ├── backend-deploy.yml
        ├── frontend-deploy.yml
        └── mobile-build.yml
```

### 3.1. Backend

#### `backend/Dockerfile`
```dockerfile
# syntax=docker/dockerfile:1.7

# ---- base: PHP-FPM + extension + php.ini production + OPcache ----
FROM php:8.3-fpm-alpine AS base
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
# Thêm extension mà app cần (bcmath, intl, gd, ...) vào dòng dưới
RUN install-php-extensions pdo_pgsql opcache zip \
 && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && { echo 'opcache.enable=1'; \
      echo 'opcache.memory_consumption=128'; \
      echo 'opcache.max_accelerated_files=20000'; \
      echo 'opcache.validate_timestamps=0'; \
      echo 'upload_max_filesize=20M'; \
      echo 'post_max_size=20M'; } > "$PHP_INI_DIR/conf.d/zz-app.ini"

# ---- vendor: cài thư viện bằng chính image có đủ extension (KHÔNG dùng --ignore-platform-reqs) ----
FROM base AS vendor
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_CACHE_DIR=/tmp/composer-cache
WORKDIR /app
COPY backend/composer.json backend/composer.lock ./
RUN --mount=type=cache,target=/tmp/composer-cache \
    composer install --no-dev --prefer-dist --no-scripts --no-autoloader --no-interaction
COPY backend/ ./
RUN composer dump-autoload --no-dev --classmap-authoritative --no-interaction

# ---- runtime ----
FROM base AS runtime
WORKDIR /var/www/html
COPY --from=vendor --chown=www-data:www-data /app ./
RUN printf '#!/bin/sh\nset -e\ncd /var/www/html\nphp artisan optimize --no-interaction || echo "WARN: artisan optimize loi (route dung closure?)"\nexec "$@"\n' > /usr/local/bin/entrypoint \
 && chmod +x /usr/local/bin/entrypoint \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwX storage bootstrap/cache
EXPOSE 9000
ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]
```

Điểm khác bản gốc: cài vendor bằng *chính image có đủ extension* (không còn `--ignore-platform-reqs` che lỗi thiếu extension); autoload tối ưu (`--classmap-authoritative`); `php.ini-production` + OPcache (`validate_timestamps=0` vì code bất biến trong image); `artisan optimize` chạy lúc container khởi động (lúc đó mới có đủ biến môi trường); bỏ `chmod 0777`, chỉ cấp quyền cho `www-data`. Nếu `composer dump-autoload` lỗi do script của package, thêm `--no-scripts` và chạy `php artisan package:discover` trong entrypoint.

#### `backend/Dockerfile.dockerignore`
Đặt cạnh `Dockerfile` (context của compose là thư mục cha `..` nên `.dockerignore` ở `backend/` thường **không có tác dụng**; BuildKit ưu tiên file `<tên Dockerfile>.dockerignore`):
```text
**/.env
**/.env.*
!**/.env.example
**/vendor
**/node_modules
**/.git
**/tests
```
> Bản gốc `COPY backend/ .` kéo luôn `backend/.env` (do Ansible vừa render) vào image ⇒ mật khẩu DB và client secret nằm vĩnh viễn trong layer image.

#### `backend/docker/nginx.conf`
```nginx
server {
    listen 80;
    server_name _;
    root /var/www/html/public;
    index index.php;
    client_max_body_size 20m;

    # Resolve lại tên container qua DNS nội bộ của Docker: backend bị tạo lại (đổi IP) vẫn không bị 502
    resolver 127.0.0.11 valid=10s ipv6=off;
    set $php_upstream lms_backend:9000;

    location / { try_files $uri /index.php?$query_string; }

    location ~ ^/index\.php(/|$) {
        fastcgi_pass $php_upstream;
        include fastcgi.conf;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ \.php$ { return 404; }
    location ~ /\.(?!well-known) { deny all; }
}
```
> Nginx resolve tên `lms_backend` **một lần lúc khởi động**; khi backend bị tạo lại (IP mới) mà web không restart thì trả 502. `resolver 127.0.0.11` + biến trong `fastcgi_pass` buộc nginx resolve lại theo DNS nội bộ của Docker.

#### `backend/docker-compose.yml`
```yaml
services:
  lms_db:
    image: postgres:16-alpine
    container_name: lms_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_DATABASE}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes: [lms_pg_data:/var/lib/postgresql/data]
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 20
    mem_limit: 1g
    networks: [lms_net]

  lms_backend:
    build:
      context: ..
      dockerfile: backend/Dockerfile
    image: lms_backend:latest
    container_name: lms_backend
    restart: unless-stopped
    env_file: [.env]
    depends_on:
      lms_db: { condition: service_healthy }
    volumes: [lms_storage:/var/www/html/storage/app]   # file upload không mất khi deploy lại
    mem_limit: 512m
    networks: [lms_net]

  lms_web:
    image: nginx:alpine
    container_name: lms_web
    restart: unless-stopped
    ports: ["127.0.0.1:8081:80"]
    volumes:
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      lms_backend: { condition: service_started }
    healthcheck:                       # đi qua cả nginx -> php-fpm -> Laravel (route /up có sẵn từ Laravel 11)
      test: ["CMD-SHELL", "wget -q -O /dev/null http://127.0.0.1/up || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 12
      start_period: 20s
    mem_limit: 128m
    networks: [lms_net]

volumes:
  lms_pg_data:
  lms_storage:
networks:
  lms_net:
```
> Bản gốc dùng `${LMS_DB_PASSWORD}` nhưng `.env` do Ansible tạo chỉ có `DB_PASSWORD` ⇒ Compose thay bằng chuỗi rỗng và Postgres không khởi tạo được. Nay compose dùng đúng các khóa `DB_*` của `.env`.

### 3.2. Ansible deploy

#### `deploy/templates/lms.env.j2`
```env
APP_NAME=LMS
APP_ENV=production
APP_KEY={{ app_key }}
APP_DEBUG=false
APP_URL=https://{{ api_domain }}

LOG_CHANNEL=stderr
LOG_LEVEL=warning

DB_CONNECTION=pgsql
DB_HOST=lms_db
DB_PORT=5432
DB_DATABASE=lms
DB_USERNAME=lms_user
DB_PASSWORD={{ db_password }}

# Nếu xác thực hoàn toàn bằng Bearer JWT của Keycloak thì không cần session/Sanctum stateful
SESSION_DRIVER=file
SANCTUM_STATEFUL_DOMAINS={{ frontend_origin | replace('https://', '') }}
CORS_ALLOWED_ORIGINS={{ frontend_origin }}

KEYCLOAK_BASE_URL=https://{{ auth_domain }}
KEYCLOAK_REALM=lms
KEYCLOAK_CLIENT_ID=lms-web
KEYCLOAK_CLIENT_SECRET={{ kc_client_secret | default('') }}
KEYCLOAK_REDIRECT_URI={{ frontend_origin }}/auth/callback
```

#### `deploy/lms.yml`
```yaml
---
- name: Deploy LMS backend
  hosts: all
  become: true
  vars:
    dir: /opt/lms/backend
    db_password: "{{ lookup('env', 'LMS_DB_PASSWORD') }}"
    app_key: "{{ lookup('env', 'LMS_APP_KEY') }}"
    kc_client_secret: "{{ lookup('env', 'LMS_KC_CLIENT_SECRET') }}"

  pre_tasks:
    - name: Kiểm tra biến bắt buộc
      ansible.builtin.assert:
        that:
          - db_password | length >= 12
          - app_key is match('^base64:[A-Za-z0-9+/]{43}=$')
          - api_domain | default('') | length > 0
          - auth_domain | default('') | length > 0
          - frontend_origin | default('') is match('^https://[^/]+$')
        fail_msg: "Thiếu/sai LMS_DB_PASSWORD (>=12 ký tự), LMS_APP_KEY (dạng base64:...) hoặc api_domain/auth_domain/frontend_origin"

  tasks:
    - name: Ensure dirs
      ansible.builtin.file:
        path: "{{ dir }}"
        state: directory

    - name: Template .env (APP_KEY cố định lấy từ secret)
      ansible.builtin.template:
        src: templates/lms.env.j2
        dest: "{{ dir }}/.env"
        mode: "0600"

    - name: Build & start stack (đợi tất cả healthy)
      ansible.builtin.command: docker compose up -d --build --wait --wait-timeout 300
      args: { chdir: "{{ dir }}" }

    - name: Migrate
      ansible.builtin.command: docker exec -u www-data lms_backend php artisan migrate --force
      register: migrate
      changed_when: "'Nothing to migrate' not in migrate.stdout"

    - name: Wait API (/up)
      ansible.builtin.uri:
        url: http://127.0.0.1:8081/up
        status_code: 200
      register: api
      until: api.status == 200
      retries: 20
      delay: 3

    - name: Dọn image cũ
      ansible.builtin.command: docker image prune -f
      changed_when: false

    - name: Thư mục backup
      ansible.builtin.file:
        path: /opt/backups
        state: directory
        mode: "0700"

    - name: Backup Postgres 02:30 mỗi ngày (giữ 7 ngày)
      ansible.builtin.cron:
        name: lms-pg-backup
        minute: "30"
        hour: "2"
        job: >-
          docker exec lms_postgres pg_dump -U lms_user lms | gzip > /opt/backups/lms-$(date +\%F).sql.gz
          && find /opt/backups -name 'lms-*.sql.gz' -mtime +7 -delete
```
> `APP_KEY` lấy từ secret `LMS_APP_KEY` và render cố định. Bản gốc render `APP_KEY=` rỗng ở mỗi lần deploy rồi chạy `key:generate` *bên trong container* (chỉ sửa file trong container; và nhiều khả năng biến `APP_KEY` rỗng do `env_file` inject còn ưu tiên hơn file `.env`) ⇒ hoặc 500, hoặc key đổi sau mỗi lần container được tạo lại.

### 3.3. Ba workflow

#### `.github/workflows/backend-deploy.yml`
```yaml
name: LMS Backend → Oracle
on:
  push:
    branches: [main]
    paths: ['backend/**', 'deploy/**']
  workflow_dispatch:
concurrency:
  group: lms-backend-deploy
  cancel-in-progress: false
permissions:
  contents: read
jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    env:
      SERVER_IP: ${{ vars.SERVER_IP }}
    steps:
      - uses: actions/checkout@v4

      - name: Prepare SSH (key + known_hosts)
        env:
          SSH_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        run: |
          : "${SERVER_IP:?Chưa đặt Variable SERVER_IP}"
          install -m 700 -d ~/.ssh
          printf '%s\n' "$SSH_KEY" > ~/.ssh/id_deploy
          chmod 600 ~/.ssh/id_deploy
          ssh-keyscan -H "$SERVER_IP" >> ~/.ssh/known_hosts

      - name: Sync backend code (rsync, xoá file thừa trên server)
        run: |
          rsync -az --delete \
            --exclude='.env' --exclude='vendor/' --exclude='node_modules/' --exclude='.git/' \
            -e "ssh -i ~/.ssh/id_deploy" \
            backend/ "ubuntu@${SERVER_IP}:/opt/lms/backend/"

      - name: Install ansible-core
        run: pip install --quiet ansible-core

      - name: Run playbook
        working-directory: deploy
        env:
          LMS_DB_PASSWORD: ${{ secrets.LMS_DB_PASSWORD }}
          LMS_APP_KEY: ${{ secrets.LMS_APP_KEY }}
          LMS_KC_CLIENT_SECRET: ${{ secrets.LMS_KC_CLIENT_SECRET }}
        run: >
          ansible-playbook -i "${SERVER_IP},"
          -u ubuntu --private-key ~/.ssh/id_deploy lms.yml
          -e api_domain=${{ vars.API_DOMAIN }}
          -e auth_domain=${{ vars.AUTH_DOMAIN }}
          -e frontend_origin=${{ vars.FRONTEND_ORIGIN }}
```

#### `.github/workflows/frontend-deploy.yml`
Thêm `netlify-cli` vào devDependencies để lockfile ghim phiên bản: `cd frontend && npm i -D netlify-cli` (commit cả `package-lock.json`).
```yaml
name: LMS Frontend → Netlify
on:
  push:
    branches: [main]
    paths: ['frontend/**']
  workflow_dispatch:
concurrency:
  group: lms-frontend-deploy
  cancel-in-progress: true
permissions:
  contents: read
jobs:
  deploy:
    runs-on: ubuntu-latest
    timeout-minutes: 15
    defaults:
      run:
        working-directory: frontend
    env:
      NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
      NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 22
          cache: npm
          cache-dependency-path: frontend/package-lock.json
      - run: npm ci
      - run: npm run build
        env:
          VITE_API_BASE_URL: https://${{ vars.API_DOMAIN }}
          VITE_KEYCLOAK_URL: https://${{ vars.AUTH_DOMAIN }}
          VITE_KEYCLOAK_REALM: lms
          VITE_KEYCLOAK_CLIENT_ID: lms-web
      - name: Deploy (netlify-cli ghim phiên bản qua devDependencies)
        run: npx netlify deploy --prod --dir=dist
```

#### `.github/workflows/mobile-build.yml`
```yaml
name: LMS Mobile → APK artifact
on:
  push:
    branches: [main]
    paths: ['mobile/**']
  workflow_dispatch:
permissions:
  contents: read
jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 30
    defaults:
      run:
        working-directory: mobile
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with:
          distribution: temurin
          java-version: 17
      - uses: subosito/flutter-action@v2
        with:
          channel: stable          # cần tái lập build: thêm flutter-version: x.y.z
          cache: true
      - run: flutter pub get
      - name: Build APK
        run: >
          flutter build apk --release --split-per-abi
          --dart-define=API_BASE_URL=https://${{ vars.API_DOMAIN }}
          --dart-define=KEYCLOAK_URL=https://${{ vars.AUTH_DOMAIN }}
          --dart-define=KEYCLOAK_REALM=lms
          --dart-define=KEYCLOAK_CLIENT_ID=lms-mobile
      - uses: actions/upload-artifact@v4
        with:
          name: lms-mobile-apk
          path: mobile/build/app/outputs/flutter-apk/*.apk
          retention-days: 14
```
> APK `--release` mặc định ký bằng debug key (đủ để cài thử, không đủ để lên Play Store). Muốn phát hành: thêm keystore vào Secrets và cấu hình `signingConfigs` trong `android/app/build.gradle`.

### 3.4. Frontend: chi tiết nhỏ bắt buộc
File `frontend/public/_redirects` (SPA routing trên Netlify):
```text
/*  /index.html  200
```

### 3.5. Chỉnh trong code Laravel (ngoài phạm vi pipeline nhưng thiếu là lỗi)
```php
// bootstrap/app.php (Laravel 11+): phía trước là 2 lớp nginx, Laravel phải tin X-Forwarded-*
// nếu không URL/redirect sinh ra là http:// và trình duyệt chặn mixed content từ trang https của Netlify.
->withMiddleware(function (Middleware $middleware): void {
    $middleware->trustProxies(at: '*');
})
```
```php
// config/cors.php: Laravel KHÔNG tự đọc CORS_ALLOWED_ORIGINS, phải khai báo
'allowed_origins' => array_filter(explode(',', env('CORS_ALLOWED_ORIGINS', ''))),
```
- Route `/up` (healthcheck của compose và bước "Wait API") có sẵn từ **Laravel 11**; Laravel 10 trở xuống phải tự thêm một route trả 200 và đổi đường dẫn trong compose + playbook.
- Nếu app chỉ xác thực bằng Bearer JWT của Keycloak thì không cần `SANCTUM_STATEFUL_DOMAINS` / `SESSION_DRIVER=file`. Frontend (`*.netlify.app`) và API (`*.duckdns.org`) là **cross-site**, cookie phiên kiểu Sanctum SPA sẽ không hoạt động ổn định.

---

## PHẦN 4: REPO agrichain (khác biệt so với LMS)

Cấu trúc cây thư mục và 3 workflow tương tự LMS (đổi tên job/group, và: `API_DOMAIN=agri-api-vnic.duckdns.org`, `FRONTEND_ORIGIN=https://agri-vnic.netlify.app`, realm `agrichain`, port `8082`, thư mục server `/opt/agrichain`). Dưới đây là các file KHÁC BIỆT:

### `backend/Dockerfile`
Giống LMS, chỉ đổi dòng cài extension ở stage `base`:
```dockerfile
RUN install-php-extensions pdo_mysql opcache zip mongodb redis \
```
(Giữ nguyên các lệnh `php.ini` / OPcache phía dưới như LMS. Bản gốc chỉ cài `pdo_mysql` bằng gói `libmariadb-dev-compat` — là tên gói Debian, Alpine không dùng tên này; `pdo_mysql` dùng `mysqlnd` nên không cần thư viện ngoài — và thiếu hẳn extension MongoDB/Redis mà `.env` đang yêu cầu.)

> **Cassandra từ PHP:** theo mình biết driver PHP của DataStax đã ngừng bảo trì và không hỗ trợ PHP 8.x — hãy kiểm tra lại trước khi dựa vào nó trong Laravel. Neo4j (`bolt`), MQTT, Redis (nếu dùng predis) là thư viện thuần PHP nên không vướng.

### `backend/docker/nginx.conf`
Giống LMS, chỉ đổi dòng upstream:
```nginx
set $php_upstream agri_backend:9000;
```

### `backend/docker-compose.yml` — stack cơ sở dữ liệu đầy đủ
```yaml
services:
  agri_mysql:
    image: mysql:8.4                      # 8.0 đã EOL 30/04/2026
    container_name: agrichain_mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_USER: ${DB_USERNAME}
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes: [agri_mysql_data:/var/lib/mysql]
    healthcheck:
      test: ["CMD-SHELL", "mysqladmin ping -h 127.0.0.1 -uroot -p$${MYSQL_ROOT_PASSWORD} --silent"]
      interval: 10s
      timeout: 5s
      retries: 20
      start_period: 30s
    mem_limit: 1g
    networks: [agri_net]

  agri_mongo:
    image: mongo:7
    container_name: agrichain_mongo
    restart: unless-stopped
    command: ["--wiredTigerCacheSizeGB", "0.25"]
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    volumes: [agri_mongo_data:/data/db]
    healthcheck:
      test: ["CMD-SHELL", "mongosh --quiet --eval 'db.adminCommand({ping:1}).ok' | grep -q 1"]
      interval: 10s
      timeout: 5s
      retries: 12
      start_period: 20s
    mem_limit: 512m
    networks: [agri_net]

  agri_cassandra:
    image: cassandra:4.1
    container_name: agrichain_cassandra
    restart: unless-stopped
    environment:
      MAX_HEAP_SIZE: 512M
      HEAP_NEWSIZE: 100M
    volumes: [agri_cassandra_data:/var/lib/cassandra]
    healthcheck:
      test: ["CMD-SHELL", "cqlsh -e 'DESCRIBE KEYSPACES' > /dev/null 2>&1"]
      interval: 30s
      timeout: 10s
      retries: 10
      start_period: 120s
    mem_limit: 1500m
    networks: [agri_net]

  agri_neo4j:
    image: neo4j:5
    container_name: agrichain_neo4j
    restart: unless-stopped
    environment:
      NEO4J_AUTH: neo4j/${NEO4J_PASSWORD}
      NEO4J_server_memory_heap_initial__size: 256m     # đặt tường minh, nếu không Neo4j tự chọn theo RAM máy chủ
      NEO4J_server_memory_heap_max__size: 512m
      NEO4J_server_memory_pagecache_size: 128m
    volumes: [agri_neo4j_data:/data]
    healthcheck:
      test: ["CMD-SHELL", "wget -q --spider http://127.0.0.1:7474 || exit 1"]
      interval: 15s
      timeout: 5s
      retries: 10
      start_period: 60s
    mem_limit: 1g
    networks: [agri_net]

  agri_redis:
    image: redis:7-alpine
    container_name: agrichain_redis
    restart: unless-stopped
    command: ["redis-server", "--requirepass", "${REDIS_PASSWORD}", "--appendonly", "yes"]
    environment:
      REDISCLI_AUTH: ${REDIS_PASSWORD}                 # để healthcheck không phải dùng `redis-cli -a`
    volumes: [agri_redis_data:/data]
    healthcheck:
      test: ["CMD-SHELL", "redis-cli ping | grep -q PONG"]
      interval: 10s
      timeout: 3s
      retries: 10
    mem_limit: 256m
    networks: [agri_net]

  agri_mosquitto:
    image: eclipse-mosquitto:2
    container_name: agrichain_mosquitto
    restart: unless-stopped
    # KHÔNG publish 1883/9001 ra Internet (plaintext). Backend gọi qua mạng nội bộ agri_net.
    # Thiết bị IoT bên ngoài: dùng 8883 + TLS + ACL thay vì mở 1883.
    volumes:
      - ./mosquitto:/mosquitto/config:ro               # mount CẢ THƯ MỤC, tránh Docker tự tạo "passwd" thành thư mục
      - agri_mosquitto_data:/mosquitto/data
    mem_limit: 128m
    networks: [agri_net]

  agri_backend:
    build:
      context: ..
      dockerfile: backend/Dockerfile
    image: agri_backend:latest
    container_name: agrichain_backend
    restart: unless-stopped
    env_file: [.env]
    depends_on:
      agri_mysql:     { condition: service_healthy }
      agri_redis:     { condition: service_healthy }
      agri_mongo:     { condition: service_healthy }
      agri_cassandra: { condition: service_started }
      agri_neo4j:     { condition: service_started }
      agri_mosquitto: { condition: service_started }
    volumes: [agri_storage:/var/www/html/storage/app]
    mem_limit: 512m
    networks: [agri_net]

  agri_web:
    image: nginx:alpine
    container_name: agrichain_web
    restart: unless-stopped
    ports: ["127.0.0.1:8082:80"]
    volumes:
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on:
      agri_backend: { condition: service_started }
    healthcheck:
      test: ["CMD-SHELL", "wget -q -O /dev/null http://127.0.0.1/up || exit 1"]
      interval: 10s
      timeout: 3s
      retries: 12
      start_period: 20s
    mem_limit: 128m
    networks: [agri_net]

volumes:
  agri_mysql_data:
  agri_mongo_data:
  agri_cassandra_data:
  agri_neo4j_data:
  agri_redis_data:
  agri_mosquitto_data:
  agri_storage:
networks:
  agri_net:
```
- MySQL 8.0 đã hết vòng đời hỗ trợ (EOL 30/04/2026) → dùng 8.4 LTS.
- **Không publish** 1883/9001 ra Internet (plaintext). Nếu thiết bị IoT bên ngoài cần kết nối, thêm listener TLS (8883) + ACL, đừng mở lại 1883.
- Tổng `mem_limit` của cả VM (Keycloak + LMS + AgriChain) ≈ **8,5 GB**. Kiểm tra `free -h` trước; VM nhỏ hơn thì giảm stack hoặc thêm swap. Neo4j/Cassandra/Mongo đã được đặt heap/cache tường minh để không vượt giới hạn container.

### `backend/mosquitto/mosquitto.conf`
```text
# Tuỳ chọn toàn cục (đặt TRƯỚC các listener)
persistence true
persistence_location /mosquitto/data/
allow_anonymous false
password_file /mosquitto/config/passwd

listener 1883
protocol mqtt

listener 9001
protocol websockets
```

### `deploy/templates/agri.env.j2`
```env
APP_NAME=Agrichain
APP_ENV=production
APP_KEY={{ app_key }}
APP_DEBUG=false
APP_URL=https://{{ api_domain }}

LOG_CHANNEL=stderr
LOG_LEVEL=warning

DB_CONNECTION=mysql
DB_HOST=agri_mysql
DB_PORT=3306
DB_DATABASE=agrichain
DB_USERNAME=agrichain
DB_PASSWORD={{ mysql_password }}
MYSQL_ROOT_PASSWORD={{ mysql_root_password }}

REDIS_HOST=agri_redis
REDIS_PORT=6379
REDIS_PASSWORD={{ redis_password }}

MONGO_PASSWORD={{ mongo_password }}
MONGO_URI=mongodb://root:{{ mongo_password }}@agri_mongo:27017/?authSource=admin
CASSANDRA_HOST=agri_cassandra
NEO4J_URL=bolt://agri_neo4j:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD={{ neo4j_password }}

MQTT_HOST=agri_mosquitto
MQTT_PORT=1883
MQTT_USER={{ mqtt_user }}
MQTT_PASSWORD={{ mqtt_password }}

SESSION_DRIVER=file
SANCTUM_STATEFUL_DOMAINS={{ frontend_origin | replace('https://', '') }}
CORS_ALLOWED_ORIGINS={{ frontend_origin }}

KEYCLOAK_BASE_URL=https://{{ auth_domain }}
KEYCLOAK_REALM=agrichain
KEYCLOAK_CLIENT_ID=agrichain-web
KEYCLOAK_CLIENT_SECRET={{ kc_client_secret | default('') }}
KEYCLOAK_REDIRECT_URI={{ frontend_origin }}/auth/callback
```

### `deploy/agrichain.yml`
```yaml
---
- name: Deploy AgriChain backend
  hosts: all
  become: true
  vars:
    dir: /opt/agrichain/backend
    app_key: "{{ lookup('env', 'AGRI_APP_KEY') }}"
    mysql_root_password: "{{ lookup('env', 'AGRI_MYSQL_ROOT_PASSWORD') }}"
    mysql_password: "{{ lookup('env', 'AGRI_MYSQL_PASSWORD') }}"
    mongo_password: "{{ lookup('env', 'AGRI_MONGO_PASSWORD') }}"
    neo4j_password: "{{ lookup('env', 'AGRI_NEO4J_PASSWORD') }}"
    redis_password: "{{ lookup('env', 'AGRI_REDIS_PASSWORD') }}"
    mqtt_password: "{{ lookup('env', 'AGRI_MQTT_PASSWORD') }}"
    kc_client_secret: "{{ lookup('env', 'AGRI_KC_CLIENT_SECRET') }}"

  pre_tasks:
    - name: Kiểm tra biến bắt buộc
      ansible.builtin.assert:
        that:
          - app_key is match('^base64:[A-Za-z0-9+/]{43}=$')
          - mysql_root_password | length >= 12
          - mysql_password | length >= 12
          - mongo_password | length >= 12
          - neo4j_password | length >= 12
          - redis_password | length >= 12
          - mqtt_password | length >= 12
          - mqtt_user | default('') | length > 0
          - api_domain | default('') | length > 0
          - auth_domain | default('') | length > 0
          - frontend_origin | default('') is match('^https://[^/]+$')
        fail_msg: "Thiếu/sai secret AGRI_* (>=12 ký tự) hoặc biến mqtt_user/api_domain/auth_domain/frontend_origin"

  tasks:
    - name: Ensure dirs
      ansible.builtin.file:
        path: "{{ dir }}/mosquitto"
        state: directory

    - name: Template .env
      ansible.builtin.template:
        src: templates/agri.env.j2
        dest: "{{ dir }}/.env"
        mode: "0600"

    # Mật khẩu truyền qua biến môi trường (không nằm trên command line / trong log)
    - name: Create mosquitto password file
      ansible.builtin.shell: >
        docker run --rm --user 0 -e MQTT_USER -e MQTT_PASSWORD
        -v {{ dir }}/mosquitto:/mosquitto/config
        eclipse-mosquitto:2
        sh -c 'mosquitto_passwd -b -c /mosquitto/config/passwd "$MQTT_USER" "$MQTT_PASSWORD"'
      environment:
        MQTT_USER: "{{ mqtt_user }}"
        MQTT_PASSWORD: "{{ mqtt_password }}"
      args:
        creates: "{{ dir }}/mosquitto/passwd"
      no_log: true

    - name: passwd thuộc user mosquitto (uid 1883), người khác không đọc được
      ansible.builtin.file:
        path: "{{ dir }}/mosquitto/passwd"
        owner: "1883"
        group: "1883"
        mode: "0600"

    - name: Build & start stack (đợi tất cả healthy; Cassandra khởi động chậm)
      ansible.builtin.command: docker compose up -d --build --wait --wait-timeout 600
      args: { chdir: "{{ dir }}" }

    - name: Migrate
      ansible.builtin.command: docker exec -u www-data agrichain_backend php artisan migrate --force
      register: migrate
      changed_when: "'Nothing to migrate' not in migrate.stdout"

    - name: Wait API (/up)
      ansible.builtin.uri:
        url: http://127.0.0.1:8082/up
        status_code: 200
      register: api
      until: api.status == 200
      retries: 20
      delay: 3

    - name: Dọn image cũ
      ansible.builtin.command: docker image prune -f
      changed_when: false

    - name: Thư mục backup
      ansible.builtin.file:
        path: /opt/backups
        state: directory
        mode: "0700"

    - name: Backup MySQL 03:00 mỗi ngày (giữ 7 ngày)
      ansible.builtin.cron:
        name: agri-mysql-backup
        minute: "0"
        hour: "3"
        job: >-
          docker exec agrichain_mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --no-tablespaces agrichain'
          | gzip > /opt/backups/agri-$(date +\%F).sql.gz
          && find /opt/backups -name 'agri-*.sql.gz' -mtime +7 -delete
```

### Workflow backend: hai step khác LMS
```yaml
# Chỉ khác workflow LMS ở 2 step dưới (các step khác giữ nguyên, đổi tên group/concurrency)
- name: Sync backend code (rsync, xoá file thừa trên server)
  run: |
    rsync -az --delete \
      --exclude='.env' --exclude='mosquitto/passwd' --exclude='vendor/' --exclude='node_modules/' --exclude='.git/' \
      -e "ssh -i ~/.ssh/id_deploy" \
      backend/ "ubuntu@${SERVER_IP}:/opt/agrichain/backend/"

- name: Run playbook
  working-directory: deploy
  env:
    AGRI_APP_KEY: ${{ secrets.AGRI_APP_KEY }}
    AGRI_MYSQL_ROOT_PASSWORD: ${{ secrets.AGRI_MYSQL_ROOT_PASSWORD }}
    AGRI_MYSQL_PASSWORD: ${{ secrets.AGRI_MYSQL_PASSWORD }}
    AGRI_MONGO_PASSWORD: ${{ secrets.AGRI_MONGO_PASSWORD }}
    AGRI_NEO4J_PASSWORD: ${{ secrets.AGRI_NEO4J_PASSWORD }}
    AGRI_REDIS_PASSWORD: ${{ secrets.AGRI_REDIS_PASSWORD }}
    AGRI_MQTT_PASSWORD: ${{ secrets.AGRI_MQTT_PASSWORD }}
    AGRI_KC_CLIENT_SECRET: ${{ secrets.AGRI_KC_CLIENT_SECRET }}
  run: >
    ansible-playbook -i "${SERVER_IP},"
    -u ubuntu --private-key ~/.ssh/id_deploy agrichain.yml
    -e api_domain=${{ vars.API_DOMAIN }}
    -e auth_domain=${{ vars.AUTH_DOMAIN }}
    -e frontend_origin=${{ vars.FRONTEND_ORIGIN }}
    -e mqtt_user=${{ vars.MQTT_USER }}
```

---

## PHẦN 5: KEYCLOAK — 2 REALM RIÊNG

Đăng nhập `https://auth-vnic.duckdns.org/admin` bằng user `admin` + mật khẩu `KC_ADMIN_PASSWORD`. Đây là *admin tạm thời* (bootstrap): tạo một admin thật rồi xoá tài khoản tạm.

Với mỗi realm (`lms`, `agrichain`):
1. **Create realm** → đặt tên tương ứng.
2. **Client cho web (SPA)** — `lms-web` (hoặc `agrichain-web`):
   - **Client authentication = OFF** (public client), **Standard flow = ON**, **Direct access grants = OFF**.
   - **Advanced → Proof Key for Code Exchange Code Challenge Method = `S256`** (PKCE).
   - **Valid redirect URIs**: `https://lms-vnic.netlify.app/auth/callback` (agrichain: `https://agri-vnic.netlify.app/auth/callback`). Dùng URI chính xác thay vì `/*` khi có thể.
   - **Valid post logout redirect URIs**: `https://lms-vnic.netlify.app/*`.
   - **Web origins**: `https://lms-vnic.netlify.app` (hoặc `https://agri-vnic.netlify.app`).
   - **Không** đưa `http://localhost:*` vào realm production; môi trường dev dùng client riêng (`lms-web-dev`) hoặc realm dev.
3. **Backend là resource server**: xác thực JWT bằng JWKS `https://auth-vnic.duckdns.org/realms/lms/protocol/openid-connect/certs`, kiểm tra `iss` = `https://auth-vnic.duckdns.org/realms/lms` và `aud`. Tạo client `lms-api` và thêm **Audience mapper** (Client scopes → `lms-web-dedicated` → Add mapper → *Audience*, Included Client Audience = `lms-api`) để token chứa đúng `aud`.
4. **Client cho mobile (Flutter)** — `lms-mobile`: public + PKCE `S256`, redirect URI dạng custom scheme (ví dụ `vn.vnic.lms://oauth/callback`) khớp với cấu hình Android/iOS của app. Workflow mobile đã truyền `KEYCLOAK_CLIENT_ID=lms-mobile`. *(Bản gốc thiếu hẳn client này.)*
5. **Chỉ khi** backend phải tự đổi `code → token` (mô hình BFF) mới dùng **confidential client**: bật *Client authentication*, copy **Client secret** vào GitHub Secrets `LMS_KC_CLIENT_SECRET` / `AGRI_KC_CLIENT_SECRET`, và **không** dùng client đó trực tiếp từ keycloak-js/SPA (public SPA không thể giữ secret; token endpoint sẽ trả `invalid_client`). Với mô hình ở các bước 2–3 thì không cần secret nào.
6. Tạo Roles + User test.

**Realm-as-code** (tuỳ chọn): export realm ra `import/lms-realm.json`, rồi trong `/opt/keycloak/docker-compose.yml` đổi `command: ["start", "--import-realm"]` và thêm `volumes: [./import:/opt/keycloak/data/import:ro]`. Keycloak chỉ import khi realm *chưa tồn tại*, nên sửa realm đã chạy phải làm qua Admin Console/API.

---

## PHẦN 6: THỨ TỰ VẬN HÀNH + KIỂM TRA

### 6.1. Thứ tự chạy lần đầu
1. **Ngoài code**: OCI mở TCP 443 (và nên gán Reserved IP); DuckDNS 3 domain trỏ `140.245.54.161`; tạo 2 site Netlify; sinh secret (1.4) và SSH key (1.5); đặt Secrets/Variables cho cả 3 repo theo bảng 7.2.
2. **Repo server-bootstrap** → Actions → **Bootstrap Server** → Run workflow (lần đầu ~5–10 phút: cài Docker, dựng Keycloak, xin cert).
3. Mở `https://auth-vnic.duckdns.org/admin` kiểm tra đăng nhập được.
4. **Cấu hình Keycloak** (Phần 5) — tạo realm + client **trước** khi deploy app.
5. **Repo lms** → push `main` → 3 pipeline tự chạy theo `paths`. **Repo agrichain** → tương tự.
6. Nếu dùng confidential client (Phần 5, bước 5): thêm secret `*_KC_CLIENT_SECRET` rồi bấm **Run workflow** cho pipeline **Backend** (secret này được dùng ở *backend*; frontend không có secret Keycloak nào để build lại).

> Sửa **Variables** (ví dụ `FRONTEND_ORIGIN`) không tự kích hoạt workflow: hãy bấm **Run workflow** (mọi workflow đều có `workflow_dispatch`).

### 6.2. Kiểm tra cuối
```bash
curl -I https://lms-api-vnic.duckdns.org/up        # 200 + chứng chỉ hợp lệ (cần Laravel 11+ hoặc route tương đương)
curl -I https://agri-api-vnic.duckdns.org/up
curl -I https://auth-vnic.duckdns.org/admin        # 302 → /admin/master/console/
curl http://140.245.54.161/health                  # "OK"

# trên server:
cd /opt/lms/backend && docker compose ps           # mọi service phải "healthy"/"running"
docker logs --tail 50 lms_backend
```

- Mở [https://lms-vnic.netlify.app](https://lms-vnic.netlify.app) → đăng nhập SSO `sv01` → vào app thành công.
- Mở [https://agri-vnic.netlify.app](https://agri-vnic.netlify.app) → đăng nhập SSO farmer test.
- GitHub → repo lms → **Actions** → **LMS Mobile → APK artifact** → **Artifacts** → tải APK (mỗi ABI một file; điện thoại hiện đại dùng `app-arm64-v8a-release.apk`).

---

## PHẦN 7: BẢNG LỖI THƯỜNG GẶP & CHECKLIST

### 7.1. Bảng lỗi thường gặp

| Hiện tượng | Nguyên nhân | Cách khắc phục |
| :--- | :--- | :--- |
| **`a duplicate default server for 0.0.0.0:80`** | Site `default` của gói nginx còn bật cùng `00-health` | Bản v2 đã gỡ; thủ công: `rm /etc/nginx/sites-enabled/default && nginx -t` |
| **Certbot fail / timeout** | DNS chưa trỏ, hoặc 80/443 bị chặn ở Security List *hoặc* iptables của VM | `nslookup` + Security List + `sudo iptables -L INPUT -n --line-numbers` |
| **`Host key verification failed`** (Ansible/rsync) | Runner mới chưa có host key của server | Step *Prepare SSH* đã `ssh-keyscan`; kiểm tra Variable `SERVER_IP` không rỗng |
| **rsync `Permission denied`** | `/opt/lms` (hoặc `/opt/agrichain`) không thuộc user `ubuntu` | Chạy lại bootstrap (task *Create dirs*) hoặc `sudo chown ubuntu /opt/lms` |
| **`Load key ... invalid format`** | Secret `SSH_PRIVATE_KEY` thiếu dòng `-----BEGIN ...`/`-----END ...` hoặc mất xuống dòng | Dán lại toàn bộ nội dung file khóa |
| **"Wait keycloak ready" quá thời gian** | Health ở cổng 9000 và cần `KC_HEALTH_ENABLED=true`; hoặc Keycloak lỗi khởi động | `docker logs keycloak_server`; `curl 127.0.0.1:9000/health/ready` trên server |
| **502 ở Keycloak: "upstream sent too big header"** | Thiếu `proxy_buffer_size` cho header/cookie lớn | Template vhost v2 đã có 3 dòng buffer |
| **413 Request Entity Too Large** | `client_max_body_size` mặc định 1m | v2 đặt 20m ở nginx host + nginx container + `post_max_size` PHP; file lớn hơn thì tăng cả ba |
| **Laravel 500 sau deploy** | `APP_KEY` sai/thiếu, hoặc lỗi cấu hình | `docker logs lms_backend`; kiểm tra secret `LMS_APP_KEY` có dạng `base64:...` |
| **DB không khởi tạo: "password option is not specified"** | Biến Compose không có trong `.env` | v2 đã khớp; kiểm tra `docker compose config` không còn cảnh báo "variable is not set" |
| **Đổi mật khẩu DB trong Secrets nhưng app không kết nối được** | Mật khẩu chỉ áp dụng ở lần khởi tạo volume đầu | Đổi bằng `ALTER USER` trong DB, hoặc xoá volume (mất dữ liệu) |
| **`lms_web` trả 502 sau khi deploy lại** | Nginx giữ IP cũ của backend | v2 dùng `resolver`; thủ công: `docker compose restart lms_web` |
| **Netlify reload 404** | Thiếu `_redirects` cho SPA | Thêm `frontend/public/_redirects` với `/* /index.html 200` |
| **SSO Invalid redirect URI** | Chưa khai báo URI Netlify trên Keycloak | Thêm vào *Valid redirect URIs* của client (Phần 5) |
| **CORS block** | `FRONTEND_ORIGIN` sai (có `/` cuối, sai scheme) hoặc `config/cors.php` không đọc biến | Sửa Variable → **Run workflow** backend; xem mục 3.5 |
| **Mosquitto crash loop / `Unable to open pwfile`** | `passwd` thiếu, là *thư mục*, hoặc sai chủ sở hữu | Playbook tạo `passwd` thuộc uid 1883 mode 0600; nếu đang là thư mục: `sudo rm -rf /opt/agrichain/backend/mosquitto/passwd` rồi chạy lại |
| **Container bị kill (OOM)** | Tổng giới hạn RAM vượt RAM thật của VM | `docker inspect -f '{{.State.OOMKilled}}' <tên>`; `free -h`; thêm swap hoặc giảm stack |

### 7.2. Checklist Secrets & Variables tổng (mỗi repo)

| Repo | Secrets | Variables |
| :--- | :--- | :--- |
| **server-bootstrap** | `SSH_PRIVATE_KEY`<br>`KC_DB_PASSWORD`<br>`KC_ADMIN_PASSWORD` | `SERVER_IP`<br>`CERT_EMAIL` |
| **lms** | `SSH_PRIVATE_KEY`<br>`LMS_DB_PASSWORD`<br>`LMS_APP_KEY`<br>`LMS_KC_CLIENT_SECRET` *(chỉ khi dùng confidential client)*<br>`NETLIFY_SITE_ID`<br>`NETLIFY_AUTH_TOKEN` | `SERVER_IP`<br>`API_DOMAIN`<br>`AUTH_DOMAIN`<br>`FRONTEND_ORIGIN` |
| **agrichain** | `SSH_PRIVATE_KEY`<br>`AGRI_APP_KEY`<br>`AGRI_MYSQL_ROOT_PASSWORD`<br>`AGRI_MYSQL_PASSWORD`<br>`AGRI_MONGO_PASSWORD`<br>`AGRI_NEO4J_PASSWORD`<br>`AGRI_REDIS_PASSWORD`<br>`AGRI_MQTT_PASSWORD`<br>`AGRI_KC_CLIENT_SECRET` *(chỉ khi dùng confidential client)*<br>`NETLIFY_SITE_ID`<br>`NETLIFY_AUTH_TOKEN` | `SERVER_IP`<br>`API_DOMAIN`<br>`AUTH_DOMAIN`<br>`FRONTEND_ORIGIN`<br>`MQTT_USER` |

Quy ước đặt tên: secret của AgriChain đều có tiền tố `AGRI_`, của LMS có tiền tố `LMS_` (bản gốc dùng lẫn `AGRI_DB_PASSWORD`, `MYSQL_*`, `AGRI_*`). Mật khẩu: `openssl rand -hex 24`; `*_APP_KEY`: xem 1.4. Mật khẩu ≥ 12 ký tự (playbook sẽ dừng nếu ngắn hơn).

---

## PHẦN 8: TỐI ƯU NÂNG CAO (tuỳ chọn)

**Build image ở CI, server chỉ `pull`** — nhanh hơn, tái lập được, rollback bằng cách deploy lại tag cũ (tham khảo, chưa chạy thử):
```yaml
# thêm vào job (permissions: contents: read, packages: write)
- uses: docker/setup-buildx-action@v3
- uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
- uses: docker/build-push-action@v6
  with:
    context: .
    file: backend/Dockerfile
    push: true
    tags: ghcr.io/${{ github.repository }}/backend:${{ github.sha }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
```
Trong compose thay `build:` bằng `image: ghcr.io/<owner>/<repo>/backend:${IMAGE_TAG}`, trên server `docker login ghcr.io` bằng PAT quyền `read:packages` (hoặc để package public), rồi playbook chạy `docker compose pull && docker compose up -d --wait`.

**Khác**
- Keycloak: tự build image với `kc.sh build` + `start --optimized` để khởi động nhanh hơn (hiện `start` tự build lại mỗi lần container được tạo mới).
- Backup mới chỉ có Postgres (LMS) và MySQL (AgriChain); Mongo/Neo4j/Cassandra cần kế hoạch riêng (`mongodump`, `neo4j-admin database dump`, snapshot volume). Nên chép backup ra ngoài VM (OCI Object Storage).
- Thêm swap 2–4 GB cho VM nhiều service Java; theo dõi `docker stats --no-stream`.
- Dùng UptimeRobot / Healthchecks.io gọi `/up` để được báo khi API chết.
- GitHub **Environments** có *required reviewers* cho job deploy production.

---

## PHỤ LỤC A: LỖI CỦA BẢN GỐC ĐÃ SỬA TRONG V2

| # | Vị trí bản gốc | Lỗi | Mức |
| :-- | :--- | :--- | :--- |
| 1 | Phần 2 — nginx | `00-health` có `default_server` trùng site `default` của gói ⇒ `nginx -t` fail *(đã tái hiện)* | Chặn |
| 2 | Phần 2 — chờ Keycloak | Health ở cổng 9000 và cần `KC_HEALTH_ENABLED` ⇒ chờ 5 phút rồi fail | Chặn |
| 3 | Phần 3/4 — compose ↔ `.env` | `LMS_DB_PASSWORD`, `MYSQL_ROOT_PASSWORD`, `MYSQL_PASSWORD`, `MONGO_PASSWORD` không có trong `.env` ⇒ DB không khởi tạo *(đã đối chiếu bằng script)* | Chặn |
| 4 | Phần 3.2 — `APP_KEY` | Render rỗng mỗi lần deploy, `key:generate` chạy trong container ⇒ 500 hoặc key đổi liên tục | Chặn |
| 5 | Workflow — SSH | Không có `known_hosts` ⇒ Ansible `Host key verification failed` | Chặn |
| 6 | Workflow — `scp-action` | `/opt/lms` thuộc root, user `ubuntu` không ghi được ⇒ fail ngay lần đầu (mục 7.1 gốc chẩn đoán nhầm là "khóa SSH sai") | Chặn |
| 7 | Phần 4 — Dockerfile | `libmariadb-dev-compat` là gói Debian; thiếu ext MongoDB/Redis; `--ignore-platform-reqs` che lỗi | Chặn |
| 8 | Phần 2 — certbot | Chạy lại bootstrap ghi đè vhost đã được certbot sửa ⇒ mất HTTPS | Cao |
| 9 | Phần 2/4 — cổng | Keycloak `8080` và Mosquitto `1883/9001` publish ra mọi interface | Cao |
| 10 | Phần 3 — Dockerfile | `.env` bị `COPY` vào image; `chmod 0777`; chạy root | Cao |
| 11 | Phần 1.2 | Image Ubuntu OCI chặn cổng bằng iptables, chỉ mở Security List là chưa đủ | Cao |
| 12 | Workflow | Secret qua `-e` trên command line; biến tự tham chiếu trong `bootstrap.yml` | Trung bình |
| 13 | Phiên bản | MySQL 8.0 EOL 30/04/2026; Node 20 hết hỗ trợ; Keycloak 26.0 cũ và `KEYCLOAK_ADMIN*` deprecated; Flutter 3.24 cũ | Trung bình |
| 14 | Phần 5 — Keycloak | SPA dùng confidential client; thiếu client mobile; `localhost:*` ở production; cookie cross-site | Trung bình |
| 15 | Thiếu | Healthcheck, resolver upstream, buffer proxy Keycloak, `client_max_body_size`, log rotation, backup, trusted proxies Laravel | Trung bình |
| 16 | Tài liệu | Tên secret không nhất quán (`AGRI_DB_PASSWORD` / `MYSQL_*` / `AGRI_*`); thiếu `MQTT_USER`; bước 6.1.6 bảo build lại *frontend* nhưng secret Keycloak dùng ở *backend*; nhắc `samco-realm.json` không có trong tài liệu; "wait task như mẫu bootstrap trước" không tồn tại; IP và email thật nằm trong tài liệu | Thấp |
