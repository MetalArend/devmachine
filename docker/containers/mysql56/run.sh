#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# MySQL on Docker - https://registry.hub.docker.com/_/mysql/
# ====== ====== ====== ====== ====== ======

# http://txt.fliglio.com/2013/11/creating-a-mysql-docker-container/
# TODO http://stackoverflow.com/questions/28346752/accessing-environment-variables-in-docker-containers-linked-with-link

CONTAINER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTAINER_NAME="$(basename "${CONTAINER_DIR}")"

#MYSQL_ROOT_PASSWORD="root"
#MYSQL_USER="docker"
#MYSQL_PASSWORD="docker"
#MYSQL_DATABASE="test"

#sudo docker run --name "${CONTAINER_NAME}" -it -e MYSQL_ROOT_PASSWORD=root "mysql:5.6" "/usr/bin/mysqld_safe"
#sudo docker run --name "${CONTAINER_NAME}" -t -c 'exec mysql -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD"'
sudo docker run --name "${CONTAINER_NAME}" -d -p 3306:3306 -t --volumes-from "app" "devmachine:${CONTAINER_NAME}-image" ""