#!/usr/bin/env bash

# http://marmelab.com/blog/2014/09/10/make-docker-command.html

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
sudo docker build --tag "devmachine:${CONTAINER_NAME}-image" "${CONTAINER_DIR}"