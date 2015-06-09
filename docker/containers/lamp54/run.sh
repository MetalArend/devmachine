#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# LAMP on Docker
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"

DB_CONTAINER_NAME="mysql56"
PHP_FPM_CONTAINER_NAME="php54-fpm"

# TODO multiple ports 80 don't show up in the reporting
sudo docker run --name "${CONTAINER_NAME}" -p 8054:80 -p 80:80 -d -t --volumes-from "data" \
--link "${PHP_FPM_CONTAINER_NAME}":"php" --link "${DB_CONTAINER_NAME}":"db" \
"devmachine:${CONTAINER_NAME}-image" -DFOREGROUND
