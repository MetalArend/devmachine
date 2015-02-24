#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Apache2 on Docker - http://programster.blogspot.be/2014/01/docker-build-apachephp-image-from.html
# ====== ====== ====== ====== ====== ======

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
mkdir -p "${CONTAINER_DIR}/data/log"
sudo docker run --name "${CONTAINER_NAME}" -d -t --volume "${CONTAINER_DIR}/data/log":"/log" --volumes-from "projects" "devmachine:${CONTAINER_NAME}-image" "-DFOREGROUND"