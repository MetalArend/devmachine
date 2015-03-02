#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# SSH on Docker
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
mkdir -p "${CONTAINER_DIR}/data/log"
sudo docker run --name "${CONTAINER_NAME}" -d -p 2222:22 -t --volumes-from "data" "devmachine:${CONTAINER_NAME}-image" "-D"