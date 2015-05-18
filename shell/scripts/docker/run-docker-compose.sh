#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker compose
# ====== ====== ====== ====== ====== ======

if which docker-compose &> /dev/null; then

    CWD=$(pwd)
    cd "/env/"
    docker-compose up
    cd "${CWD}"

fi