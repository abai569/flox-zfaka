#!/bin/bash
set -euo pipefail

INSTALL_DIR="${ZFAKA_INSTALL_DIR:-/opt/flox-zfaka}"
COMPOSE_URL="https://raw.githubusercontent.com/abai569/flox-zfaka/main/docker-compose.yml"
SCRIPT_URL="https://raw.githubusercontent.com/abai569/flox-zfaka/main/install.sh"
ACTION="${1:-install}"

is_command_available() {
  command -v "$1" >/dev/null 2>&1
}

detect_package_manager() {
  local manager
  for manager in apt-get dnf yum zypper apk; do
    if is_command_available "$manager"; then
      printf '%s\n' "$manager"
      return 0
    fi
  done
  return 1
}

install_packages() {
  local manager
  if ! manager=$(detect_package_manager); then
    echo "[ERROR] Unsupported Linux distribution: apt-get, dnf, yum, zypper, or apk is required" >&2
    return 1
  fi

  echo "[INFO] Installing required packages: $*"
  case "$manager" in
    apt-get)
      DEBIAN_FRONTEND=noninteractive apt-get update
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$@"
      ;;
    dnf) dnf install -y "$@" ;;
    yum) yum install -y "$@" ;;
    zypper) zypper --non-interactive install --no-recommends "$@" ;;
    apk) apk add --no-cache "$@" ;;
  esac
}

has_ca_certificates() {
  [ -s /etc/ssl/certs/ca-certificates.crt ] || [ -s /etc/pki/tls/certs/ca-bundle.crt ] || [ -s /etc/ssl/cert.pem ]
}

ensure_common_tools() {
  local tool missing=0
  for tool in curl openssl gzip readlink cp date mkdir chmod rm mktemp id; do
    if ! is_command_available "$tool"; then
      echo "[INFO] Missing command: $tool"
      missing=1
    fi
  done
  if ! has_ca_certificates; then
    echo "[INFO] Missing CA certificate bundle"
    missing=1
  fi
  if [ "$missing" -eq 0 ]; then
    return 0
  fi

  install_packages ca-certificates curl openssl gzip coreutils || return 1

  for tool in curl openssl gzip readlink cp date mkdir chmod rm mktemp id; do
    if ! is_command_available "$tool"; then
      echo "[ERROR] Required command is still unavailable after installation: $tool" >&2
      return 1
    fi
  done
  if ! has_ca_certificates; then
    echo "[ERROR] CA certificates are still unavailable after installation" >&2
    return 1
  fi
}

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

start_docker() {
  if docker info >/dev/null 2>&1; then
    return 0
  fi

  echo "[INFO] Starting Docker service"
  if is_command_available systemctl; then
    systemctl enable docker >/dev/null 2>&1 || true
    systemctl start docker >/dev/null 2>&1 || true
  fi
  if ! docker info >/dev/null 2>&1 && is_command_available rc-update && is_command_available rc-service; then
    rc-update add docker default >/dev/null 2>&1 || true
    rc-service docker start >/dev/null 2>&1 || true
  fi
  if ! docker info >/dev/null 2>&1 && is_command_available service; then
    service docker start >/dev/null 2>&1 || true
  fi

  local attempt=0
  while [ "$attempt" -lt 30 ]; do
    if docker info >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
    attempt=$((attempt + 1))
  done
  echo "[ERROR] Docker daemon is not running; check the service logs for details" >&2
  return 1
}

install_docker() {
  local manager installer
  manager=$(detect_package_manager) || {
    echo "[ERROR] Docker cannot be installed automatically on this Linux distribution" >&2
    return 1
  }

  echo "[INFO] Installing Docker Engine and Docker Compose"
  case "$manager" in
    apk)
      install_packages docker docker-cli-compose
      ;;
    zypper)
      install_packages docker docker-compose
      ;;
    *)
      installer=$(mktemp)
      if ! curl -fsSL https://get.docker.com -o "$installer"; then
        rm -f "$installer"
        echo "[ERROR] Failed to download the Docker installer" >&2
        return 1
      fi
      if ! sh "$installer"; then
        rm -f "$installer"
        echo "[ERROR] Docker installation failed" >&2
        return 1
      fi
      rm -f "$installer"
      ;;
  esac
}

ensure_compose() {
  if docker compose version >/dev/null 2>&1 || is_command_available docker-compose; then
    return 0
  fi

  local manager
  manager=$(detect_package_manager) || {
    echo "[ERROR] Docker Compose cannot be installed automatically on this Linux distribution" >&2
    return 1
  }
  echo "[INFO] Installing Docker Compose"
  case "$manager" in
    apk) install_packages docker-cli-compose ;;
    zypper) install_packages docker-compose ;;
    *) install_docker ;;
  esac

  if ! docker compose version >/dev/null 2>&1 && ! is_command_available docker-compose; then
    echo "[ERROR] Docker Compose is still unavailable after installation" >&2
    return 1
  fi
}

ensure_docker() {
  ensure_common_tools || return 1
  if ! is_command_available docker; then
    install_docker || return 1
  fi
  if ! is_command_available docker; then
    echo "[ERROR] Docker is still unavailable after installation" >&2
    return 1
  fi
  start_docker || return 1
  ensure_compose || return 1
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
  if ! [[ "$port" =~ ^[0-9]{1,5}$ ]] || [ "$port" -lt 1 ] || [ "$port" -gt 65535 ]; then
    echo "[ERROR] Port must be between 1 and 65535"
    exit 1
  fi

  curl -fsSL "$COMPOSE_URL" -o docker-compose.yml
  curl -fsSL "$SCRIPT_URL" -o install.sh
  chmod 0755 install.sh
  umask 077
  admin_email="demo@demo.com"
  admin_password="admin123"
  cat > .env <<EOF
MYSQL_ROOT_PASSWORD=$(random_secret)
DB_NAME=faka
DB_USER=faka
DB_PASSWORD=$(random_secret)
ADMIN_EMAIL=$admin_email
ADMIN_PASSWORD=$admin_password
ADMIN_DIR=Goadmin
ZFAKA_PORT=$port
ZFAKA_IMAGE=ghcr.io/abai569/flox-zfaka:latest
EOF

  compose pull
  compose up -d
  echo "[INFO] Waiting for ZFAKA to become healthy"
  local attempt=0
  while [ "$attempt" -lt 60 ]; do
    if curl -fsS "http://127.0.0.1:$port/" >/dev/null 2>&1; then
      echo "[OK] ZFAKA is available at http://SERVER_IP:$port/"
      echo "[INFO] Admin URL: http://SERVER_IP:$port/Goadmin/login"
      echo "[INFO] Initial account: $admin_email / $admin_password"
      echo "[IMPORTANT] Change the initial account and password immediately"
      return
    fi
    sleep 3
    attempt=$((attempt + 1))
  done
  compose logs --tail=100 zfaka-web
  echo "[ERROR] ZFAKA did not become healthy"
  exit 1
}

update_zfaka() {
  require_root
  ensure_docker
  cd "$INSTALL_DIR"
  curl -fsSL "$COMPOSE_URL" -o docker-compose.yml
  compose pull
  compose up -d
  docker image prune -f >/dev/null 2>&1 || true
  echo "[OK] ZFAKA has been updated"
}

backup_zfaka() {
  require_root
  ensure_docker
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
  ensure_docker
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

uninstall_zfaka() {
  require_root
  ensure_docker
  option="${2:-}"
  if [ "$option" != "" ] && [ "$option" != "--volumes" ]; then
    echo "Usage: $0 uninstall [--volumes]"
    exit 1
  fi
  if [ "${3:-}" != "" ]; then
    echo "Usage: $0 uninstall [--volumes]"
    exit 1
  fi

  cd "$INSTALL_DIR"
  if [ "$option" = "--volumes" ]; then
    compose down --volumes
    cd /
    rm -rf "$INSTALL_DIR"
    echo "[OK] ZFAKA containers, data volumes, and installation files removed"
  else
    compose down
    echo "[OK] ZFAKA containers removed; data volumes retained"
  fi
}

main() {
  case "$ACTION" in
    install) install_zfaka ;;
    update) update_zfaka ;;
    backup) backup_zfaka ;;
    restore) restore_zfaka "$@" ;;
    uninstall) uninstall_zfaka "$@" ;;
    status) require_root; ensure_docker; cd "$INSTALL_DIR" && compose ps ;;
    logs) require_root; ensure_docker; cd "$INSTALL_DIR" && compose logs -f --tail=200 ;;
    *) echo "Usage: $0 {install|update|backup|restore|uninstall|status|logs}"; exit 1 ;;
  esac
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
  main "$@"
fi
