#!/usr/bin/env bash

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
sudo docker build --tag "devmachine:${CONTAINER_NAME}-image" "${CONTAINER_DIR}"