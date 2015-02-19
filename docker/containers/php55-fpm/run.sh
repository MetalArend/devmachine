#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# PHP5-FPM on Docker
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
sudo docker run --name "${CONTAINER_NAME}" -p 9000 -d -t --volumes-from "app" "devmachine:${CONTAINER_NAME}-image"