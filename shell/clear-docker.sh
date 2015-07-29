#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker clear
# ====== ====== ====== ====== ====== ======

CONTAINER_IDS_ALL=$(sudo docker ps --all --quiet --no-trunc)
for CONTAINER_ID in ${CONTAINER_IDS_ALL}; do
    if test -n "$(sudo docker ps --quiet --no-trunc | grep "${CONTAINER_ID}")"; then
        sudo docker stop "${CONTAINER_ID}"
    fi
    if test -n "$(sudo docker ps --all --quiet --no-trunc | grep "${CONTAINER_ID}")"; then
        sudo docker rm --force "${CONTAINER_ID}"
    fi
done

IMAGE_IDS_ALL=$(sudo docker images --all --quiet --no-trunc)
for IMAGE_ID in ${IMAGE_IDS_ALL}; do
    if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID}")"; then
        sudo docker rmi --force "${IMAGE_ID}"
    fi
done

sudo docker ps --all --no-trunc | grep -v "CONTAINER"

sudo docker images --all --no-trunc | grep -v "IMAGE"