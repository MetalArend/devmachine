#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# MySQL on Docker - http://txt.fliglio.com/2013/11/creating-a-mysql-docker-container/
# ====== ====== ====== ====== ====== ======

# TODO https://registry.hub.docker.com/_/mysql/
# TODO http://stackoverflow.com/questions/28346752/accessing-environment-variables-in-docker-containers-linked-with-link

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"
sudo docker run --name "${CONTAINER_NAME}" -d -p 3306:3306 -t --volumes-from "app" "devmachine:${CONTAINER_NAME}-image" ""