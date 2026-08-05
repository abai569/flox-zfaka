FROM php:7.4-fpm-bullseye

ARG APP_VERSION=1.4.7
ENV APP_VERSION=${APP_VERSION}

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        cron \
        curl \
        default-mysql-client \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libonig-dev \
        libpng-dev \
        libzip-dev \
        nginx \
        supervisor \
        unzip; \
    docker-php-ext-configure gd --with-freetype --with-jpeg; \
    docker-php-ext-install -j"$(nproc)" curl gd mbstring pdo_mysql zip; \
    pecl install yaf-3.3.5; \
    docker-php-ext-enable yaf; \
    printf '%s\n' 'yaf.use_namespace=1' 'date.timezone=Asia/Shanghai' 'upload_max_filesize=100M' 'post_max_size=100M' > /usr/local/etc/php/conf.d/zfaka.ini; \
    rm -f /etc/nginx/sites-enabled/default; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

COPY . .
COPY docker/nginx.conf /etc/nginx/conf.d/zfaka.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/zfaka.conf
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
COPY docker/cron /etc/cron.d/zfaka

RUN set -eux; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    chmod 0644 /etc/cron.d/zfaka; \
    mkdir -p log/php log/request log/sql log/sqld log/crontab log/yewu log/upgrade temp public/res/upload; \
    chown -R www-data:www-data /var/www/html; \
    chmod -R u+rwX,g+rwX conf install log temp public/res/upload

LABEL org.opencontainers.image.source="https://github.com/abai569/flox-zfaka" \
      org.opencontainers.image.version="${APP_VERSION}"

EXPOSE 80

HEALTHCHECK --interval=15s --timeout=5s --start-period=60s --retries=5 \
    CMD curl -fsS http://127.0.0.1/ >/dev/null || exit 1

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
