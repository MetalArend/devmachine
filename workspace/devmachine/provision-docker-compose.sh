#!/usr/bin/env bash

set -e

source "/env/shell/common.sh"

# Run commands in current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CWD}"

# Run docker-compose
#echo -e "\e[33mRun docker-compose\e[0m"
#docker-compose stop && docker-compose rm -f && docker-compose build && docker-compose up -d && docker-compose ps

# Check php server
#echo -e "\e[33mCheck php server\e[0m"
#check_container --container "php55fpm" --port 9000 --timeout 10

# Install composer packages
#echo -e "\e[33mInstall composer packages\e[0m"
#docker-compose run --rm --entrypoint /bin/bash "php55fpm" -c "cd devmachine && composer install"