#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker compose
# ====== ====== ====== ====== ====== ======

if which docker-compose &> /dev/null; then

    # Variables
    CONFIG_DIR=""
    while getopts "d:" OPTION; do
        case "${OPTION}" in
            d)
                CONFIG_DIR="${OPTARG}"
                ;;
            *)
                return
                ;;
        esac
    done
    if test "" = "${CONFIG_DIR}"; then
        return
    fi

    # Compose docker
    WORKING_DIR=$(pwd)
    cd "${CONFIG_DIR}"
    docker-compose ps
    cd "${WORKING_DIR}"

fi