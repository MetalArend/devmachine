#!/usr/bin/env bash

set -e

source "/env/shell/common.sh"

# Run commands in current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CWD}"

# Run docker-compose
echo -e "\e[33mRun docker-compose\e[0m"
docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d && docker-compose ps

# Check php server
echo -e "\e[33mCheck php server\e[0m"
check_container --container "php" --port 9000 --timeout 10

# Install composer packages
echo -e "\e[33mInstall composer packages\e[0m"
docker-compose run --rm --entrypoint /bin/bash "php" -c "composer install"

## Check database server
#echo -e "\e[33mCheck database server\e[0m"
#check_container --container "db" --port 3306 --timeout 20

## Add database and user
#echo -e "\e[33mAdd database and user\e[0m"
#docker run --link "$(docker inspect --format="{{.Name}}" "$(docker-compose ps -q "db")")":mysql --rm mysql sh -c 'exec mysql -v -v -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS stagesol;" -e "GRANT ALL PRIVILEGES ON stagesol.* TO \"stagesol\"@\"%\" IDENTIFIED BY \"stagesol\";" -e "FLUSH PRIVILEGES;"'