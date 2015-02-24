#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Data volume on docker
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
mkdir -p "/app/devmachine/.devmachine/log"
sudo docker run --name "${CONTAINER_NAME}" -v "/app":"/var/www" -v "/app/devmachine/.devmachine/log":"/log" "busybox" true