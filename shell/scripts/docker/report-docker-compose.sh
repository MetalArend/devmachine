#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Report docker compose
# ====== ====== ====== ====== ====== ======

if which docker-compose &> /dev/null; then
    DOCKER_COMPOSE_VERSION=$(docker-compose --version | sed 's/^[^0-9]* //g')
    echo -e "\e[92m- docker-compose ${DOCKER_COMPOSE_VERSION}\e[0m"
else
    echo -e "\e[91m- docker-compose not found\e[0m"
fi
echo " "