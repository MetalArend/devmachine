#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Report docker
# ====== ====== ====== ====== ====== ======

if which docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version | sed 's/^[^0-9]* //g')
    echo -e "\e[92m- docker ${DOCKER_VERSION}\e[0m"
    echo -e "\e[92m  $(docker info 2>/dev/null | sed -n -e '/Containers:.*/,/Images:.*/p' | sed ':a;N;s/\n/, /g')\e[0m"
else
    echo -e "\e[91m- docker not found\e[0m"
fi
echo " "