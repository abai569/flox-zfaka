#!/bin/sh
set -eu

: "${APP_PATH:=/var/www/html}"
: "${DB_HOST:=db}"
: "${DB_PORT:=3306}"
: "${DB_NAME:=zfaka}"
: "${DB_USER:=zfaka}"
: "${DB_PASSWORD:?DB_PASSWORD is required}"
: "${ADMIN_DIR:=Admin}"
: "${ADMIN_EMAIL:=admin@example.com}"
: "${ADMIN_PASSWORD:?ADMIN_PASSWORD is required}"
: "${ZFAKA_VERSION:=1.4.9}"

mkdir -p "$APP_PATH/conf" "$APP_PATH/install" "$APP_PATH/log/php" "$APP_PATH/log/request" "$APP_PATH/log/sqld" "$APP_PATH/log/crontab" "$APP_PATH/log/yewu" "$APP_PATH/log/upgrade" "$APP_PATH/temp" "$APP_PATH/public/res/upload"

if [ ! -f "$APP_PATH/conf/application.ini" ]; then
    envsubst < "$APP_PATH/conf/application.ini.template" > "$APP_PATH/conf/application.ini"
fi

if [ "$ADMIN_DIR" != "Goadmin" ]; then
    if [ -d "$APP_PATH/application/modules/Goadmin" ] && [ ! -d "$APP_PATH/application/modules/$ADMIN_DIR" ]; then
        mv "$APP_PATH/application/modules/Goadmin" "$APP_PATH/application/modules/$ADMIN_DIR"
    fi
    sed -i "s/,Goadmin,/,${ADMIN_DIR},/" "$APP_PATH/conf/application.ini"
fi

if [ ! -f "$APP_PATH/install/install.lock" ]; then
    until mysqladmin ping -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" --silent; do
        sleep 2
    done

    mysql --protocol=tcp -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < /usr/local/share/zfaka/docker-seed.sql
    php "$APP_PATH/docker/scripts/init-admin.php" "$ADMIN_EMAIL" "$ADMIN_PASSWORD"
    printf '%s' "$ZFAKA_VERSION" > "$APP_PATH/install/install.lock"
fi

echo "INIT_DONE"

chown -R www-data:www-data "$APP_PATH/log" "$APP_PATH/temp" "$APP_PATH/public/res/upload"
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
