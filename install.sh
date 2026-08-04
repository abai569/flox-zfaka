#!/bin/bash
set -euo pipefail

INSTALL_DIR="${ZFAKA_INSTALL_DIR:-/opt/flox-zfaka}"
COMPOSE_URL="https://raw.githubusercontent.com/abai569/flox-zfaka/main/docker-compose.yml"
SCRIPT_URL="https://raw.githubusercontent.com/abai569/flox-zfaka/main/install.sh"
ACTION="${1:-install}"

compose() {
  if docker compose version >/dev/null 2>&1; then
    docker compose "$@"
  elif command -v docker-compose >/dev/null 2>&1; then
    docker-compose "$@"
  else
    echo "[ERROR] Docker Compose is not available"
    exit 1
  fi
}

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "[ERROR] Run this script as root"
    exit 1
  fi
}

ensure_docker() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "[INFO] Installing Docker"
    curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
  fi
  compose version >/dev/null
}

random_secret() {
  if command -v openssl >/dev/null 2>&1; then
    openssl rand -hex 24
  else
    tr -dc 'A-Za-z0-9' </dev/urandom | head -c 48
  fi
}

install_zfaka() {
  require_root
  ensure_docker
  mkdir -p "$INSTALL_DIR"
  cd "$INSTALL_DIR"

  if [ -f .env ]; then
    echo "[ERROR] An installation already exists at $INSTALL_DIR"
    exit 1
  fi

  read -r -p "Access port [8089]: " port
  port="${port:-8089}"
  read -r -p "Admin path [Admin]: " admin_dir
  admin_dir="${admin_dir:-Admin}"
  if ! [[ "$port" =~ ^[0-9]{1,5}$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "[ERROR] Port must be between 1 and 65535"
    exit 1
  fi
  if ! [[ "$admin_dir" =~ ^[A-Z][a-z]{3,10}$ ]]; then
    echo "[ERROR] Admin path must start with one uppercase letter followed by 3-10 lowercase letters"
    exit 1
  fi

  curl -fsSL "$COMPOSE_URL" -o docker-compose.yml
  curl -fsSL "$SCRIPT_URL" -o install.sh
  chmod 0755 install.sh
  umask 077
  cat > .env <<EOF
MYSQL_ROOT_PASSWORD=$(random_secret)
DB_NAME=faka
DB_USER=faka
DB_PASSWORD=$(random_secret)
ADMIN_DIR=$admin_dir
ZFAKA_PORT=$port
ZFAKA_IMAGE=ghcr.io/abai569/flox-zfaka:latest
EOF

  compose pull
  compose up -d
  echo "[INFO] Waiting for ZFAKA to become healthy"
  for _ in $(seq 1 60); do
    if curl -fsS "http://127.0.0.1:$port/" >/dev/null 2>&1; then
      echo "[OK] ZFAKA is available at http://SERVER_IP:$port/"
      echo "[INFO] Admin URL: http://SERVER_IP:$port/$admin_dir/login"
      echo "[INFO] Initial account: demo@demo.com / 123456"
      echo "[IMPORTANT] Change the initial account and password immediately"
      return
    fi
    sleep 3
  done
  compose logs --tail=100 zfaka-web
  echo "[ERROR] ZFAKA did not become healthy"
  exit 1
}

update_zfaka() {
  require_root
  cd "$INSTALL_DIR"
  curl -fsSL "$COMPOSE_URL" -o docker-compose.yml
  compose pull
  compose up -d
  docker image prune -f >/dev/null 2>&1 || true
  echo "[OK] ZFAKA has been updated"
}

backup_zfaka() {
  require_root
  cd "$INSTALL_DIR"
  mkdir -p backups
  backup="backups/zfaka-$(date +%Y%m%d-%H%M%S).sql.gz"
  compose exec -T mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" --single-transaction --routines --triggers "$MYSQL_DATABASE"' | gzip > "$backup"
  cp .env "${backup%.sql.gz}.env"
  echo "[OK] Database backup: $INSTALL_DIR/$backup"
  echo "[INFO] Docker volumes remain in place; back them up at the host or storage layer before migration"
}

restore_zfaka() {
  require_root
  file="${2:-}"
  if [ -z "$file" ] || [ ! -f "$file" ]; then
    echo "Usage: $0 restore /path/to/backup.sql.gz"
    exit 1
  fi
  file=$(readlink -f "$file")
  cd "$INSTALL_DIR"
  gzip -dc "$file" | compose exec -T mysql sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"'
  echo "[OK] Database restored from $file"
}

case "$ACTION" in
  install) install_zfaka ;;
  update) update_zfaka ;;
  backup) backup_zfaka ;;
  restore) restore_zfaka "$@" ;;
  status) cd "$INSTALL_DIR" && compose ps ;;
  logs) cd "$INSTALL_DIR" && compose logs -f --tail=200 ;;
  *) echo "Usage: $0 {install|update|backup|restore|status|logs}"; exit 1 ;;
esac
