#!/bin/sh
set -eu

APP_ROOT=/var/www/html
DB_HOST=${DB_HOST:-mysql}
DB_PORT=${DB_PORT:-3306}
DB_NAME=${DB_NAME:-faka}
DB_USER=${DB_USER:-faka}
DB_PASSWORD=${DB_PASSWORD:-zfaka_change_me}
ADMIN_DIR=${ADMIN_DIR:-Admin}
APP_VERSION_RAW=${APP_VERSION:-1.4.8}

normalize_version() {
  printf '%s' "$1" | sed 's/^[vV]//'
}

APP_VERSION_NORMALIZED=$(normalize_version "$APP_VERSION_RAW")

if ! printf '%s' "$APP_VERSION_NORMALIZED" | grep -Eq '^[0-9]+(\.[0-9]+)*$'; then
  echo "INIT_ERROR=APP_VERSION must be a release version like 1.4.8"
  exit 1
fi

if ! printf '%s' "$ADMIN_DIR" | grep -Eq '^[A-Z][a-z]{3,10}$'; then
  echo "INIT_ERROR=ADMIN_DIR must start with one uppercase letter followed by 3-10 lowercase letters"
  exit 1
fi

for db_identifier in "$DB_NAME" "$DB_USER"; do
  if ! printf '%s' "$db_identifier" | grep -Eq '^[A-Za-z0-9_]+$'; then
    echo "INIT_ERROR=DB_NAME and DB_USER may contain only letters, numbers, and underscores"
    exit 1
  fi
done

if ! printf '%s' "$DB_HOST" | grep -Eq '^[A-Za-z0-9.-]+$'; then
  echo "INIT_ERROR=DB_HOST contains unsupported characters"
  exit 1
fi
if ! printf '%s' "$DB_PORT" | grep -Eq '^[0-9]{1,5}$' || [ "$DB_PORT" -lt 1 ] || [ "$DB_PORT" -gt 65535 ]; then
  echo "INIT_ERROR=DB_PORT must be between 1 and 65535"
  exit 1
fi
if ! printf '%s' "$DB_PASSWORD" | grep -Eq '^[A-Za-z0-9._~!@%+=:-]+$'; then
  echo "INIT_ERROR=DB_PASSWORD contains unsupported characters"
  exit 1
fi

mkdir -p "$APP_ROOT/log/php" "$APP_ROOT/log/request" "$APP_ROOT/log/sql" \
  "$APP_ROOT/log/sqld" "$APP_ROOT/log/crontab" "$APP_ROOT/log/yewu" \
  "$APP_ROOT/log/upgrade" "$APP_ROOT/temp" "$APP_ROOT/public/res/upload"

find "$APP_ROOT/install" -mindepth 1 -maxdepth 1 -type d -name '1.*' -exec rm -rf {} +

if [ -d "$APP_ROOT/application/modules/Admin" ] && [ "$ADMIN_DIR" != "Admin" ]; then
  mv "$APP_ROOT/application/modules/Admin" "$APP_ROOT/application/modules/$ADMIN_DIR"
fi

sed -i "s/define('ADMIN_DIR',[^;]*;/define('ADMIN_DIR',    '$ADMIN_DIR');/" "$APP_ROOT/application/init.php"

escape_ini() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

DB_HOST_ESCAPED=$(escape_ini "$DB_HOST")
DB_PASSWORD_ESCAPED=$(escape_ini "$DB_PASSWORD")
cat > "$APP_ROOT/conf/application.ini" <<EOF
[common]
application.directory                 = APP_PATH"/application/"
application.dispatcher.catchException = True
application.cache_config              = 1
application.dispatcher.defaultController = Index
application.dispatcher.defaultAction  = index
application.view.ext                  = "html"
application.modules                   = Index,Member,Product,$ADMIN_DIR,Crontab,Install

[product : common]
TYPE = mysql
READ_HOST = "$DB_HOST_ESCAPED"
READ_PORT = $DB_PORT
READ_USER = "$DB_USER"
READ_PSWD = "$DB_PASSWORD_ESCAPED"
WRITE_HOST = "$DB_HOST_ESCAPED"
WRITE_PORT = $DB_PORT
WRITE_USER = "$DB_USER"
WRITE_PSWD = "$DB_PASSWORD_ESCAPED"
Default = "$DB_NAME"
pconnect = 0
EOF

MYSQL_CNF=$(mktemp)
trap 'rm -f "$MYSQL_CNF"' EXIT INT TERM
chmod 600 "$MYSQL_CNF"
cat > "$MYSQL_CNF" <<EOF
[client]
host=$DB_HOST
port=$DB_PORT
user=$DB_USER
password=$DB_PASSWORD
EOF

# Only perform MySQL initialization when running the main process (supervisord or no args)
if [ "$#" -eq 0 ] || echo "$*" | grep -q "supervisord"; then
  echo "[INFO] Waiting for MySQL at $DB_HOST:$DB_PORT"
  attempt=0
  until mysqladmin --defaults-extra-file="$MYSQL_CNF" ping --silent; do
    attempt=$((attempt + 1))
    if [ "$attempt" -ge 60 ]; then
      echo "INIT_ERROR=MySQL did not become ready"
      exit 1
    fi
    sleep 2
  done

  TABLE_COUNT=$(mysql --defaults-extra-file="$MYSQL_CNF" -N -B "$DB_NAME" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name='t_config';")
  if [ "$TABLE_COUNT" = "0" ]; then
    echo "[INFO] Initializing ZFAKA database"
    mysql --defaults-extra-file="$MYSQL_CNF" "$DB_NAME" < "$APP_ROOT/install/faka.sql"
    printf '%s\n' "$APP_VERSION_NORMALIZED" > "$APP_ROOT/install/install.lock"
  elif [ ! -f "$APP_ROOT/install/install.lock" ]; then
    echo "INIT_ERROR=Existing database is missing install/install.lock; restore the matching install volume or migrate manually"
    exit 1
  else
    LOCK_VERSION=$(normalize_version "$(cat "$APP_ROOT/install/install.lock")")
    case "$LOCK_VERSION" in
      1.4.6|1.4.7|"$APP_VERSION_NORMALIZED")
        printf '%s\n' "$APP_VERSION_NORMALIZED" > "$APP_ROOT/install/install.lock"
        ;;
      *)
        CURRENT_BASELINE_COUNT=$(mysql --defaults-extra-file="$MYSQL_CNF" -N -B "$DB_NAME" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='$DB_NAME' AND table_name='t_article'; SELECT COUNT(*) FROM t_payment WHERE alias IN ('paypal','uzhifu','vpayalipay','vpaywx');" | awk '{sum += $1} END {print sum}')
        if [ "$CURRENT_BASELINE_COUNT" = "5" ]; then
          printf '%s\n' "$APP_VERSION_NORMALIZED" > "$APP_ROOT/install/install.lock"
        else
          echo "INIT_ERROR=Unsupported existing install.lock version $LOCK_VERSION for Docker image $APP_VERSION_NORMALIZED"
          exit 1
        fi
        ;;
    esac
  fi

  chown -R www-data:www-data "$APP_ROOT/conf" "$APP_ROOT/install" "$APP_ROOT/log" "$APP_ROOT/temp" "$APP_ROOT/public/res/upload"
  chmod -R u+rwX,g+rwX "$APP_ROOT/conf" "$APP_ROOT/install" "$APP_ROOT/log" "$APP_ROOT/temp" "$APP_ROOT/public/res/upload"

  echo "INIT_ADMIN_URL=/$ADMIN_DIR/login"
  echo "INIT_DONE"
fi

exec "$@"
