#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker compose
# ====== ====== ====== ====== ====== ======

if which docker-compose &> /dev/null; then

    CWD=$(pwd)
    cd "/env/"
    docker-compose build
    docker-compose up -d mysql56
    cd "${CWD}"

fi