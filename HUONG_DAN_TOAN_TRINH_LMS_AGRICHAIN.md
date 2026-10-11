# HƯỚNG DẪN TOÀN TRÌNH: 2 REPO (LMS + AGRICHAIN) — CI/CD + ANSIBLE + DOCKER + NETLIFY + DUCKDNS + FLUTTER

---

## PHẦN 0: KIẾN TRÚC TỔNG THỂ

```text
┌─ REPO lms ────────────────────────────────────────────────────────┐
│ backend/  ──GH Actions──► Ansible từ runner ──► Oracle server     │
│                           (Docker: lms_db + lms_backend + lms_web)│
│                           https://lms-api-vnic.duckdns.org (:8081)│
│ frontend/ ──GH Actions──► Netlify  https://lms-vnic.netlify.app   │
│ mobile/   ──GH Actions──► artifact APK (không deploy)             │
└───────────────────────────────────────────────────────────────────┘
┌─ REPO agrichain ──────────────────────────────────────────────────┐
│ backend/  ──► Oracle (mysql,mongo,cassandra,neo4j,redis,mosquitto │
│             + agri_backend + agri_web) :8082                      │
│             https://agri-api-vnic.duckdns.org                     │
│ frontend/ ──► Netlify  https://agri-vnic.netlify.app              │
│ mobile/   ──► artifact APK                                        │
└───────────────────────────────────────────────────────────────────┘
┌─ REPO server-bootstrap (chạy 1 lần) ──────────────────────────────┐
│ Docker + Nginx + Certbot + Keycloak chung                         │
│ https://auth-vnic.duckdns.org (:8080) + TLS cho cả 3 domain       │
└───────────────────────────────────────────────────────────────────┘
```

### Bảng phân bổ Domain & Port

| Thành phần | Domain | Port nội bộ / Nơi chạy |
| :--- | :--- | :--- |
| **Keycloak (chung)** | `auth-vnic.duckdns.org` | `8080` |
| **LMS backend** | `lms-api-vnic.duckdns.org` | `127.0.0.1:8081` |
| **Agrichain backend** | `agri-api-vnic.duckdns.org` | `127.0.0.1:8082` |
| **LMS frontend** | `lms-vnic.netlify.app` | Netlify CDN |
| **Agrichain frontend** | `agri-vnic.netlify.app` | Netlify CDN |

---

## PHẦN 1: CHUẨN BỊ NGOÀI CODE

### 1.1. Đăng ký DuckDNS (3 domain, ~5 phút)
1. Mở [https://www.duckdns.org](https://www.duckdns.org) → đăng nhập bằng GitHub.
2. Lần lượt tạo 3 domain:
   - `lms-api-vnic`
   - `agri-api-vnic`
   - `auth-vnic`
3. Mỗi domain đặt `current ip` = `140.245.54.161` → bấm **Save**.
4. Ghi lại **token** (ở góc trên cùng của trang).
5. Kiểm tra từ máy local:
   ```bash
   nslookup lms-api-vnic.duckdns.org 8.8.8.8
   nslookup agri-api-vnic.duckdns.org 8.8.8.8
   nslookup auth-vnic.duckdns.org 8.8.8.8
   ```
   > Cả 3 phải trả về đúng IP `140.245.54.161`.

### 1.2. Oracle Security List
- Mở cổng **TCP 443** (cổng 80 đã có).
- Thao tác: **Console** → **Networking** → **VCN** → **Security Lists** → **Add ingress rule** (Port `443`, CIDR `0.0.0.0/0`).

### 1.3. Netlify (2 site riêng biệt)
Thực hiện 2 lần (một cho `lms` và một cho `agrichain`):
1. Truy cập [https://app.netlify.com](https://app.netlify.com) → đăng nhập GitHub.
2. **Add new site** → **Deploy manually** (kéo thả thư mục trống bất kỳ hoặc bỏ qua) → site được tạo.
3. **Site settings** → **Change site name** → đặt thành `lms-vnic` (và `agri-vnic` cho repo kia) → URL tương ứng trở thành:
   - `https://lms-vnic.netlify.app`
   - `https://agri-vnic.netlify.app`
4. **Site settings** → **General** → **Site ID** → Copy ID này.
5. **User settings** → **Applications** → **Personal access tokens** → **New access token** → Copy token (chỉ hiển thị 1 lần duy nhất).
6. Vào repo GitHub tương ứng → **Settings** → **Secrets and variables**:
   - **Secrets**:
     - `NETLIFY_SITE_ID`
     - `NETLIFY_AUTH_TOKEN`
     - `SSH_PRIVATE_KEY`
     - `LMS_DB_PASSWORD` (hoặc các secrets `AGRI_*` cho agrichain)
   - **Variables**:
     - `SERVER_IP` = `140.245.54.161`
     - `API_DOMAIN` = `lms-api-vnic.duckdns.org`
     - `AUTH_DOMAIN` = `auth-vnic.duckdns.org`
     - `FRONTEND_ORIGIN` = `https://lms-vnic.netlify.app`

---

## PHẦN 2: REPO server-bootstrap (chạy MỘT lần)

### Cấu trúc thư mục
```text
server-bootstrap/
├── inventory.ini
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

### `inventory.ini`
```ini
[app]
140.245.54.161 ansible_user=ubuntu
```

### `bootstrap.yml`
```yaml
---
- name: Bootstrap server (Docker + Nginx + Certbot + Keycloak)
  hosts: app
  become: true
  vars:
    cert_email: "ntai8448@gmail.com"
    domains:
      - { domain: "lms-api-vnic.duckdns.org",  port: 8081 }
      - { domain: "agri-api-vnic.duckdns.org", port: 8082 }
      - { domain: "auth-vnic.duckdns.org",     port: 8080 }
    kc_db_password: "{{ kc_db_password }}"      # truyền qua -e
    kc_admin_user: "admin"
    kc_admin_password: "{{ kc_admin_password }}"

  tasks:
    - name: Install base packages + nginx + certbot
      ansible.builtin.apt:
        name: [ca-certificates, curl, gnupg, rsync, nginx, certbot, python3-certbot-nginx]
        state: present
        update_cache: true

    - name: Install Docker
      ansible.builtin.shell:
        cmd: curl -fsSL https://get.docker.com | sh
        creates: /usr/bin/docker

    - name: Enable services
      ansible.builtin.systemd:
        name: "{{ item }}"
        state: started
        enabled: true
      loop: [docker, nginx]

    - name: Create keycloak dirs
      ansible.builtin.file:
        path: /opt/keycloak
        state: directory
        mode: "0755"

    - name: Deploy default health vhost
      ansible.builtin.template:
        src: health.conf.j2
        dest: /etc/nginx/sites-available/00-health
      notify: reload nginx

    - name: Deploy proxy vhosts (3 domains)
      ansible.builtin.template:
        src: vhost.conf.j2
        dest: /etc/nginx/sites-available/{{ item.domain }}
      loop: "{{ domains }}"
      loop_control: { label: "{{ item.domain }}" }
      notify: reload nginx

    - name: Enable sites
      ansible.builtin.file:
        src: /etc/nginx/sites-available/{{ item }}
        dest: /etc/nginx/sites-enabled/{{ item }}
        state: link
      loop: [00-health, lms-api-vnic.duckdns.org, agri-api-vnic.duckdns.org, auth-vnic.duckdns.org]
      notify: reload nginx

    - name: Deploy keycloak .env + compose
      ansible.builtin.template:
        src: "{{ item.src }}"
        dest: /opt/keycloak/{{ item.dest }}
        mode: "{{ item.mode }}"
      loop:
        - { src: keycloak.env.j2,          dest: .env,               mode: "0600" }
        - { src: keycloak-compose.yml.j2,  dest: docker-compose.yml, mode: "0644" }

    - name: Start keycloak
      ansible.builtin.command: docker compose up -d
      args: { chdir: /opt/keycloak }

    - name: Wait keycloak ready
      ansible.builtin.uri:
        url: http://127.0.0.1:8080/health/ready
        status_code: 200
      register: kc
      until: kc.status == 200
      retries: 60
      delay: 5

    - name: Issue Let's Encrypt SAN certificate (1 lần)
      ansible.builtin.command: >
        certbot --nginx -n --agree-tos -m {{ cert_email }} --redirect
        -d lms-api-vnic.duckdns.org
        -d agri-api-vnic.duckdns.org
        -d auth-vnic.duckdns.org
      args:
        creates: /etc/letsencrypt/live/lms-api-vnic.duckdns.org/fullchain.pem

  handlers:
    - name: reload nginx
      ansible.builtin.systemd: { name: nginx, state: reloaded }
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
server {
    listen 80;
    server_name {{ item.domain }};
    location / {
        proxy_pass http://127.0.0.1:{{ item.port }};
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### `templates/keycloak.env.j2`
```env
KC_DB_PASSWORD={{ kc_db_password }}
KC_ADMIN_USER={{ kc_admin_user }}
KC_ADMIN_PASSWORD={{ kc_admin_password }}
KC_HOSTNAME=https://auth-vnic.duckdns.org
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
    mem_limit: 512m
    networks: [kc_net]

  keycloak:
    image: quay.io/keycloak/keycloak:26.0
    container_name: keycloak_server
    restart: unless-stopped
    command: ["start"]
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://keycloak_postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: ${KC_DB_PASSWORD}
      KEYCLOAK_ADMIN: ${KC_ADMIN_USER}
      KEYCLOAK_ADMIN_PASSWORD: ${KC_ADMIN_PASSWORD}
      KC_HOSTNAME: ${KC_HOSTNAME}
      KC_PROXY_HEADERS: xforwarded
      KC_HTTP_ENABLED: "true"
    ports: ["8080:8080"]
    depends_on: [keycloak_db]
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
jobs:
  bootstrap:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Prepare SSH key
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa
      - name: Install ansible
        run: pip install ansible
      - name: Run bootstrap
        run: >
          ansible-playbook -i inventory.ini bootstrap.yml
          -e "kc_db_password=${{ secrets.KC_DB_PASSWORD }}"
          -e "kc_admin_password=${{ secrets.KC_ADMIN_PASSWORD }}"
```

---

## PHẦN 3: REPO lms (đầy đủ)

### Cấu trúc thư mục
```text
lms/
├── backend/
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── docker/
│       └── nginx.conf
├── frontend/            # React Vite + public/_redirects
├── mobile/              # Flutter
├── deploy/
│   ├── inventory.ini
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
FROM composer:2 AS vendor
WORKDIR /build
COPY backend/composer.json backend/composer.lock* ./
RUN composer install --no-dev --prefer-dist --no-scripts --ignore-platform-reqs

FROM php:8.3-fpm-alpine
RUN apk add --no-cache libpq-dev \
 && docker-php-ext-install pdo_pgsql opcache
WORKDIR /var/www/html
COPY backend/ .
COPY --from=vendor /build/vendor ./vendor
RUN chmod -R 0777 storage bootstrap/cache
EXPOSE 9000
CMD ["php-fpm"]
```

#### `backend/docker/nginx.conf`
```nginx
server {
    listen 80;
    root /var/www/html/public;
    index index.php;
    location / { try_files $uri $uri/ /index.php?$query_string; }
    location ~ \.php$ {
        fastcgi_pass lms_backend:9000;
        include fastcgi.conf;
    }
}
```

#### `backend/docker-compose.yml`
```yaml
services:
  lms_db:
    image: postgres:16-alpine
    container_name: lms_postgres
    restart: unless-stopped
    environment:
      POSTGRES_DB: lms
      POSTGRES_USER: lms_user
      POSTGRES_PASSWORD: ${LMS_DB_PASSWORD}
    volumes: [lms_pg_data:/var/lib/postgresql/data]
    mem_limit: 1g
    networks: [lms_net]

  lms_backend:
    build:
      context: ..
      dockerfile: backend/Dockerfile
    container_name: lms_backend
    restart: unless-stopped
    env_file: [.env]
    depends_on: [lms_db]
    mem_limit: 512m
    networks: [lms_net]

  lms_web:
    image: nginx:alpine
    container_name: lms_web
    restart: unless-stopped
    ports: ["127.0.0.1:8081:80"]
    volumes:
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on: [lms_backend]
    mem_limit: 128m
    networks: [lms_net]

volumes:
  lms_pg_data:
networks:
  lms_net:
```

### 3.2. Ansible deploy

#### `deploy/inventory.ini`
```ini
[app]
140.245.54.161 ansible_user=ubuntu
```

#### `deploy/templates/lms.env.j2`
```env
APP_NAME=LMS
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://{{ api_domain }}

DB_CONNECTION=pgsql
DB_HOST=lms_db
DB_PORT=5432
DB_DATABASE=lms
DB_USERNAME=lms_user
DB_PASSWORD={{ db_password }}

SESSION_DRIVER=file
SANCTUM_STATEFUL_DOMAINS={{ frontend_origin | replace('https://', '') }}
CORS_ALLOWED_ORIGINS={{ frontend_origin }}

KEYCLOAK_BASE_URL=https://{{ auth_domain }}
KEYCLOAK_REALM=lms
KEYCLOAK_CLIENT_ID=lms-web
KEYCLOAK_CLIENT_SECRET={{ kc_client_secret }}
KEYCLOAK_REDIRECT_URI={{ frontend_origin }}/auth/callback
```

#### `deploy/lms.yml`
```yaml
---
- name: Deploy LMS backend
  hosts: app
  become: true
  vars:
    dir: /opt/lms/backend
  tasks:
    - name: Ensure dirs
      ansible.builtin.file:
        path: "{{ dir }}/docker"
        state: directory

    - name: Template .env
      ansible.builtin.template:
        src: templates/lms.env.j2
        dest: "{{ dir }}/.env"
        mode: "0600"

    - name: Build & start stack
      ansible.builtin.command: docker compose up -d --build
      args: { chdir: "{{ dir }}" }

    - name: Wait Postgres
      ansible.builtin.command: docker exec lms_postgres pg_isready -U lms_user -d lms
      register: pg
      until: pg.rc == 0
      retries: 30
      delay: 5
      changed_when: false

    - name: Generate APP_KEY if missing
      ansible.builtin.shell: |
        docker exec lms_backend sh -c \
        'grep -q "^APP_KEY=base64" .env || php artisan key:generate --force'
      changed_when: false

    - name: Migrate
      ansible.builtin.command: docker exec lms_backend php artisan migrate --force
      changed_when: false

    - name: Wait API
      ansible.builtin.uri:
        url: http://127.0.0.1:8081
        status_code: [200, 302, 404]
      register: api
      until: api.status in [200, 302, 404]
      retries: 20
      delay: 3
```

### 3.3. Ba workflow

#### `.github/workflows/backend-deploy.yml`
```yaml
name: LMS Backend → Oracle
on:
  push:
    branches: [main]
    paths: ['backend/**', 'deploy/**']
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Sync backend code to server
        uses: appleboy/scp-action@v0.1.7
        with:
          host: ${{ vars.SERVER_IP }}
          username: ubuntu
          key: ${{ secrets.SSH_PRIVATE_KEY }}
          source: "backend"
          target: "/opt/lms"

      - name: Prepare SSH key for ansible
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Install ansible
        run: pip install ansible

      - name: Run playbook
        working-directory: deploy
        run: >
          ansible-playbook -i inventory.ini lms.yml
          -e "api_domain=${{ vars.API_DOMAIN }}"
          -e "auth_domain=${{ vars.AUTH_DOMAIN }}"
          -e "frontend_origin=${{ vars.FRONTEND_ORIGIN }}"
          -e "db_password=${{ secrets.LMS_DB_PASSWORD }}"
          -e "kc_client_secret=${{ secrets.LMS_KC_CLIENT_SECRET }}"
```

#### `.github/workflows/frontend-deploy.yml`
```yaml
name: LMS Frontend → Netlify
on:
  push:
    branches: [main]
    paths: ['frontend/**']
jobs:
  deploy:
    runs-on: ubuntu-latest
    defaults:
      run: { working-directory: frontend }
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci
      - run: npm run build
        env:
          VITE_API_BASE_URL: https://${{ vars.API_DOMAIN }}
          VITE_KEYCLOAK_URL: https://${{ vars.AUTH_DOMAIN }}
          VITE_KEYCLOAK_REALM: lms
          VITE_KEYCLOAK_CLIENT_ID: lms-web
      - run: >
          npx netlify-cli deploy --prod --dir=dist
          --site=${{ secrets.NETLIFY_SITE_ID }}
          --auth=${{ secrets.NETLIFY_AUTH_TOKEN }}
```

#### `.github/workflows/mobile-build.yml`
```yaml
name: LMS Mobile → APK artifact
on:
  push:
    branches: [main]
    paths: ['mobile/**']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { flutter-version: 3.24.x }
      - name: Build APK
        run: |
          cd mobile
          flutter pub get
          flutter build apk --release \
            --dart-define=API_BASE_URL=https://${{ vars.API_DOMAIN }} \
            --dart-define=KEYCLOAK_URL=https://${{ vars.AUTH_DOMAIN }} \
            --dart-define=KEYCLOAK_REALM=lms
      - uses: actions/upload-artifact@v4
        with:
          name: lms-mobile-apk
          path: mobile/build/app/outputs/flutter-apk/app-release.apk
```

### 3.4. Frontend chi tiết nhỏ bắt buộc
File `frontend/public/_redirects` (Hỗ trợ SPA routing trên Netlify):
```text
/*  /index.html  200
```

---

## PHẦN 4: REPO agrichain (khác biệt so với LMS)

Cấu trúc cây thư mục và 3 workflow tương tự LMS (đổi tên job/biến: `AGRI_DB_PASSWORD`, `AGRI_KC_CLIENT_SECRET`, `API_DOMAIN=agri-api-vnic.duckdns.org`, `FRONTEND_ORIGIN=https://agri-vnic.netlify.app`, realm `agrichain`, port `8082`). Dưới đây là các file KHÁC BIỆT:

### `backend/Dockerfile` — đổi extension sang MySQL:
```dockerfile
RUN apk add --no-cache libmariadb-dev-compat \
 && docker-php-ext-install pdo_mysql opcache
```

### `backend/docker-compose.yml` — stack cơ sở dữ liệu đầy đủ:
```yaml
services:
  agri_mysql:
    image: mysql:8.0
    container_name: agrichain_mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: agrichain
      MYSQL_USER: agrichain
      MYSQL_PASSWORD: ${MYSQL_PASSWORD}
    volumes: [agri_mysql_data:/var/lib/mysql]
    mem_limit: 1g
    networks: [agri_net]

  agri_mongo:
    image: mongo:7
    container_name: agrichain_mongo
    restart: unless-stopped
    environment:
      MONGO_INITDB_ROOT_USERNAME: root
      MONGO_INITDB_ROOT_PASSWORD: ${MONGO_PASSWORD}
    volumes: [agri_mongo_data:/data/db]
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
    mem_limit: 1500m
    networks: [agri_net]

  agri_neo4j:
    image: neo4j:5
    container_name: agrichain_neo4j
    restart: unless-stopped
    environment:
      NEO4J_AUTH: neo4j/${NEO4J_PASSWORD}
    volumes: [agri_neo4j_data:/data]
    mem_limit: 1g
    networks: [agri_net]

  agri_redis:
    image: redis:7-alpine
    container_name: agrichain_redis
    restart: unless-stopped
    command: redis-server --requirepass ${REDIS_PASSWORD}
    volumes: [agri_redis_data:/data]
    mem_limit: 256m
    networks: [agri_net]

  agri_mosquitto:
    image: eclipse-mosquitto:2
    container_name: agrichain_mosquitto
    restart: unless-stopped
    ports: ["1883:1883", "9001:9001"]
    volumes:
      - ./mosquitto/mosquitto.conf:/mosquitto/config/mosquitto.conf:ro
      - ./mosquitto/passwd:/mosquitto/config/passwd:ro
    mem_limit: 128m
    networks: [agri_net]

  agri_backend:
    build:
      context: ..
      dockerfile: backend/Dockerfile
    container_name: agrichain_backend
    restart: unless-stopped
    env_file: [.env]
    depends_on: [agri_mysql]
    mem_limit: 512m
    networks: [agri_net]

  agri_web:
    image: nginx:alpine
    container_name: agrichain_web
    restart: unless-stopped
    ports: ["127.0.0.1:8082:80"]
    volumes:
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf:ro
    depends_on: [agri_backend]
    mem_limit: 128m
    networks: [agri_net]

volumes:
  agri_mysql_data:
  agri_mongo_data:
  agri_cassandra_data:
  agri_neo4j_data:
  agri_redis_data:
networks:
  agri_net:
```

### `backend/docker/nginx.conf`
Tương tự như cấu hình LMS nhưng điều chỉnh cấu hình fastcgi pass:
```nginx
fastcgi_pass agri_backend:9000;
```

### `backend/mosquitto/mosquitto.conf`
Sử dụng cấu hình Mosquitto với 2 listener (1883 và 9001 websocket) và file mật khẩu:
```text
listener 1883
listener 9001
protocol websockets
password_file /mosquitto/config/passwd
allow_anonymous false
```

### `deploy/templates/agri.env.j2`
```env
APP_NAME=Agrichain
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=https://{{ api_domain }}

DB_CONNECTION=mysql
DB_HOST=agri_mysql
DB_PORT=3306
DB_DATABASE=agrichain
DB_USERNAME=agrichain
DB_PASSWORD={{ mysql_password }}

REDIS_HOST=agri_redis
REDIS_PASSWORD={{ redis_password }}

MONGO_URI=mongodb://root:{{ mongo_password }}@agri_mongo:27017
CASSANDRA_HOST=agri_cassandra
NEO4J_URL=bolt://agri_neo4j:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD={{ neo4j_password }}

MQTT_HOST=agri_mosquitto
MQTT_PORT=1883
MQTT_USER={{ mqtt_user }}
MQTT_PASSWORD={{ mqtt_password }}

SANCTUM_STATEFUL_DOMAINS={{ frontend_origin | replace('https://', '') }}
CORS_ALLOWED_ORIGINS={{ frontend_origin }}

KEYCLOAK_BASE_URL=https://{{ auth_domain }}
KEYCLOAK_REALM=agrichain
KEYCLOAK_CLIENT_ID=agrichain-web
KEYCLOAK_CLIENT_SECRET={{ kc_client_secret }}
KEYCLOAK_REDIRECT_URI={{ frontend_origin }}/auth/callback
```

### `deploy/agrichain.yml`
Tương tự `lms.yml`, thêm 2 task trước bước `docker compose up`:
```yaml
    - name: Create mosquitto password file
      ansible.builtin.shell: >
        docker run --rm
        -v {{ dir }}/mosquitto:/mosquitto/config
        eclipse-mosquitto:2
        mosquitto_passwd -b -c /mosquitto/config/passwd
        {{ mqtt_user }} {{ mqtt_password }}
      args:
        creates: "{{ dir }}/mosquitto/passwd"

    - name: Fix passwd ownership
      ansible.builtin.file:
        path: "{{ dir }}/mosquitto/passwd"
        mode: "0644"
```
*(kèm theo các wait task: `mysqladmin ping`, `redis-cli -a ... ping` như mẫu bootstrap trước).*

---

## PHẦN 5: KEYCLOAK — 2 REALM RIÊNG

Sau khi bootstrap xong, đăng nhập vào `https://auth-vnic.duckdns.org/admin`:

Với mỗi realm (`lms`, `agrichain`):
1. **Create realm** → Đặt tên tương ứng (`lms` hoặc `agrichain`).
2. **Clients** → **Create client**:
   - Client ID: `lms-web` (hoặc `agrichain-web`)
   - Bật **Client authentication** (Confidential).
   - **Valid redirect URIs**:
     - `https://lms-vnic.netlify.app/*`
     - `https://lms-vnic.netlify.app/auth/callback`
     - *(Với repo agrichain)*: `https://agri-vnic.netlify.app/*` và `https://agri-vnic.netlify.app/auth/callback`
     - Giữ `http://localhost:*` cho môi trường dev.
   - **Web origins**: Thêm origin Netlify tương ứng (`https://lms-vnic.netlify.app` hoặc `https://agri-vnic.netlify.app`).
3. **Credentials** → Copy **Client secret** → Lưu vào GitHub Secrets: `LMS_KC_CLIENT_SECRET` / `AGRI_KC_CLIENT_SECRET`.
4. Tạo Roles + User test.
*(Nâng cao: export realm ra JSON và mount `--import-realm` — tương tự pattern của file `samco-realm.json`: realm-as-code với clients + audience mapper + service account).*

---

## PHẦN 6: THỨ TỰ VẬN HÀNH + KIỂM TRA

### 6.1. Thứ tự chạy lần đầu
1. **OCI**: Mở TCP 443. **DuckDNS**: 3 domain trỏ IP `140.245.54.161`. **Netlify**: Tạo 2 site + thiết lập secrets.
2. **Repo server-bootstrap** → Actions → Run workflow (**Bootstrap Server**) → chờ ~3–5 phút hoàn tất.
3. **Repo lms** → push code → 3 pipeline tự động chạy theo đường dẫn `paths`.
4. **Repo agrichain** → tương tự.
5. Cấu hình Keycloak realms/clients (như hướng dẫn ở Phần 5).
6. Push lại `frontend/**` một commit nhỏ để build lại với secret Keycloak đầy đủ (nếu cần).

### 6.2. Kiểm tra cuối
Chạy các lệnh curl kiểm tra domain:
```bash
curl -I https://lms-api-vnic.duckdns.org        # Trả về 200/302/404 + SSL hợp lệ
curl -I https://agri-api-vnic.duckdns.org
curl -I https://auth-vnic.duckdns.org/admin
curl  http://140.245.54.161/health              # Trả về "OK" (keep-alive)
```

- Mở [https://lms-vnic.netlify.app](https://lms-vnic.netlify.app) → đăng nhập SSO sv01 → vào app thành công.
- Mở [https://agri-vnic.netlify.app](https://agri-vnic.netlify.app) → đăng nhập SSO farmer test.
- GitHub → repo lms → **Actions** → **mobile-build** → **Artifacts** → tải file APK cài đặt lên điện thoại.

---

## PHẦN 7: BẢNG LỖI THƯỜNG GẶP & CHECKLIST

### 7.1. Bảng lỗi thường gặp

| Hiện tượng | Nguyên nhân | Cách khắc phục |
| :--- | :--- | :--- |
| **Certbot fail** | DNS chưa trỏ / Cổng 443 chưa mở | Kiểm tra `nslookup` + Security List trên Oracle Cloud |
| **scp-action báo permission** | Khóa SSH Private Key không đúng | Kiểm tra secret `SSH_PRIVATE_KEY` (phải bao gồm cả header `-----BEGIN ...` và footer `-----END ...`) |
| **Laravel 500 sau deploy** | Thiếu `APP_KEY` hoặc chưa chạy migration | Xem logs: `docker logs lms_backend` |
| **Netlify reload 404** | Thiếu file `_redirects` cho SPA | Thêm file `_redirects` vào thư mục `public/` với nội dung `/* /index.html 200` |
| **SSO Invalid redirect URI** | Chưa khai báo URI Netlify trên Keycloak | Thêm URL Netlify vào mục *Valid redirect URIs* trong client Keycloak |
| **CORS block** | `CORS_ALLOWED_ORIGINS` sai origin Netlify | Sửa biến `FRONTEND_ORIGIN` trong GitHub Variables rồi push lại `deploy/**` |
| **Mosquitto crash loop** | File `passwd` chưa được tạo trước khi start compose | Playbook `agrichain.yml` đã xử lý bằng `creates: "{{ dir }}/mosquitto/passwd"` |

### 7.2. Checklist Secrets & Variables tổng (mỗi repo)

| Repo | Secrets | Variables |
| :--- | :--- | :--- |
| **server-bootstrap** | `SSH_PRIVATE_KEY`<br>`KC_DB_PASSWORD`<br>`KC_ADMIN_PASSWORD` | *(Không có)* |
| **lms** | `SSH_PRIVATE_KEY`<br>`LMS_DB_PASSWORD`<br>`LMS_KC_CLIENT_SECRET`<br>`NETLIFY_SITE_ID`<br>`NETLIFY_AUTH_TOKEN` | `SERVER_IP`<br>`API_DOMAIN`<br>`AUTH_DOMAIN`<br>`FRONTEND_ORIGIN` |
| **agrichain** | `SSH_PRIVATE_KEY`<br>`MYSQL_ROOT_PASSWORD`<br>`MYSQL_PASSWORD`<br>`MONGO_PASSWORD`<br>`NEO4J_PASSWORD`<br>`REDIS_PASSWORD`<br>`MQTT_PASSWORD`<br>`AGRI_KC_CLIENT_SECRET`<br>`NETLIFY_SITE_ID`<br>`NETLIFY_AUTH_TOKEN` | `SERVER_IP`<br>`API_DOMAIN`<br>`AUTH_DOMAIN`<br>`FRONTEND_ORIGIN` |
