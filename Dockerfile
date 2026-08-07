FROM php:7.4-fpm-bullseye

ARG APP_VERSION=1.5.2
ENV APP_VERSION=${APP_VERSION}
ENV ZFAKA_VERSION=${APP_VERSION}
ARG COMPOSER_VERSION=2.2.22

ENV APP_PATH=/var/www/html \
    PHP_OPCACHE_VALIDATE_TIMESTAMPS=0

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx supervisor gettext-base default-mysql-client curl libpng-dev libjpeg62-turbo-dev libfreetype6-dev libzip-dev unzip git \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" gd mysqli pdo_mysql zip opcache \
    && pecl install yaf-3.3.5 \
    && docker-php-ext-enable yaf opcache \
    && printf '%s\n' 'yaf.use_namespace=1' 'date.timezone=Asia/Shanghai' > /usr/local/etc/php/conf.d/zfaka.ini \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:2.2 /usr/bin/composer /usr/bin/composer
WORKDIR /var/www/html

COPY composer.json ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress

COPY . .
COPY docker/nginx/default.conf /etc/nginx/sites-enabled/default
COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY docker/entrypoint.sh /usr/local/bin/zfaka-entrypoint
COPY install/docker-seed.sql /usr/local/share/zfaka/docker-seed.sql

RUN rm -f conf/application.ini install/install.lock install/ka_abai_eu_org.sql install/docker-seed.sql \
    && chmod +x /usr/local/bin/zfaka-entrypoint \
    && mkdir -p /run/nginx /var/log/php-fpm

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/zfaka-entrypoint"]
