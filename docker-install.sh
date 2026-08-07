#!/bin/sh
set -eu

case "${1:-up}" in
  up)
    docker compose up -d --build
    ;;
  update)
    docker compose pull
    docker compose up -d
    ;;
  down)
    docker compose down
    ;;
  logs)
    docker compose logs -f --tail=200
    ;;
  status)
    docker compose ps
    ;;
  backup)
    mkdir -p backups
    docker compose exec -T db sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE"' > "backups/zfaka-$(date +%Y%m%d-%H%M%S).sql"
    ;;
  *)
    echo "Usage: ./docker-install.sh {up|update|down|logs|status|backup}" >&2
    exit 2
    ;;
esac
