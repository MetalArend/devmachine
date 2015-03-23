#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Data volume on docker
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
mkdir -p "/env/log"
sudo docker run --name "${CONTAINER_NAME}" -v "/var/www":"/var/www" -v "/env/log":"/log" "busybox" true