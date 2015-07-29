#!/usr/bin/env bash

set -e

source "/env/shell/common.sh"

# Set configuration
DOCUMENT_ROOT="/var/www/html/devmachine"
PHP_CONTAINER_NAME="php54fpm"
DATABASE_CONTAINER_NAME="mysql56"

# Run commands in current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CWD}"

# Run docker-compose
#echo -e "\e[33mRun docker-compose\e[0m"
#docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d
#docker-compose ps

# Check php server
#echo -e "\e[33mCheck web server\e[0m"
#check_container --container "${PHP_CONTAINER_NAME}" --port 9000 --timeout 10

# Install composer packages
#echo -e "\e[33mInstall composer packages\e[0m"
#docker-compose run --rm --entrypoint /bin/bash "${PHP_CONTAINER_NAME}" -c "cd ${DOCUMENT_ROOT} && composer install"

## Clear cache
#echo -e "\e[33mClear cache\e[0m"
#docker-compose run --rm --entrypoint /bin/bash "${PHP_CONTAINER_NAME}" -c "cd ${DOCUMENT_ROOT} && php app/console cache:clear"

# Check database server
#echo -e "\e[33mCheck database server\e[0m"
#check_container --container "${DATABASE_CONTAINER_NAME}" --port 3306 --timeout 20

# Add database and user # TODO add this to the provisioning, and use an sql file
#echo -e "\e[33mAdd database and user\e[0m"
#DATABASE_CONTAINER_INSTANCE="$(docker inspect --format="{{.Name}}" "$(docker-compose ps -q "${DATABASE_CONTAINER_NAME}")")"
#docker run --link ${DATABASE_CONTAINER_INSTANCE}:mysql --rm mysql sh -c 'exec mysql -v -v -h"$MYSQL_PORT_3306_TCP_ADDR" -P"$MYSQL_PORT_3306_TCP_PORT" -uroot -p"$MYSQL_ENV_MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE IF NOT EXISTS stagesol;" -e "GRANT ALL PRIVILEGES ON stagesol.* TO \"stagesol\"@\"%\" IDENTIFIED BY \"stagesol\";" -e "FLUSH PRIVILEGES;"'

# Recreate database
#echo -e "\e[33mRecreate database tables\e[0m"
#docker-compose run --rm --entrypoint /bin/bash "${PHP_CONTAINER_NAME}" -c "cd ${DOCUMENT_ROOT} && \
#    php app/console doctrine:schema:drop --force && \
#    php app/console doctrine:schema:create && \
#    php app/console doctrine:fixtures:load --no-interaction"