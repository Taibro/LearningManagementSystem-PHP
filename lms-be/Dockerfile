FROM php:8.3-fpm-alpine AS base
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_pgsql opcache zip \
 && cp "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
 && { echo 'opcache.enable=1'; \
      echo 'opcache.memory_consumption=128'; \
      echo 'opcache.max_accelerated_files=20000'; \
      echo 'opcache.validate_timestamps=0'; \
      echo 'upload_max_filesize=20M'; \
      echo 'post_max_size=20M'; } > "$PHP_INI_DIR/conf.d/zz-app.ini"

FROM base AS vendor
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1 COMPOSER_CACHE_DIR=/tmp/composer-cache
WORKDIR /app
COPY composer.json composer.lock ./
RUN --mount=type=cache,target=/tmp/composer-cache \
    composer install --no-dev --prefer-dist --no-scripts --no-autoloader --no-interaction
COPY . ./
RUN composer dump-autoload --no-dev --classmap-authoritative --no-interaction

# ---- runtime ----
FROM base AS runtime
WORKDIR /var/www/html
COPY --from=vendor --chown=www-data:www-data /app ./
RUN printf '#!/bin/sh\nset -e\ncd /var/www/html\nphp artisan optimize --no-interaction || echo "WARN: artisan optimize failed"\nexec "$@"\n' > /usr/local/bin/entrypoint \
 && chmod +x /usr/local/bin/entrypoint \
 && chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwX storage bootstrap/cache
EXPOSE 9000
ENTRYPOINT ["entrypoint"]
CMD ["php-fpm"]