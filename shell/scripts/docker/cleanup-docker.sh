#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker containers
# ====== ====== ====== ====== ====== ======

# Remove dead containers
CONTAINERS_IDS_DEAD="$(sudo docker ps --all --no-trunc | grep " Dead " | awk '{print $1}')"
if test -n "${CONTAINERS_IDS_DEAD}"; then
    for CONTAINER_ID_DEAD in ${CONTAINERS_IDS_DEAD}; do
        echo -e "\e[93mRemove dead container '${CONTAINER_ID_DEAD}'\e[0m"
        sudo docker rm -f "${CONTAINER_ID_DEAD}"
    done
fi

# Remove exited containers not with exit 0
if test -n "$(sudo docker ps --all --no-trunc | grep "Exit " | grep -v "Exit 0")"; then
    echo -e "\e[93mRemove exited containers not with exit 0\e[0m"
    sudo docker rm -f $(sudo docker ps --all --no-trunc | grep "Exit " | grep -v "Exit 0" | awk '{print $1}')
fi

# Remove exited containers without a tag
if test -n "$(sudo docker ps --all --no-trunc | grep "Exit 0" | awk '{print $1,$2}' | grep -v ":")"; then
    echo -e "\e[93mRemove exited containers without a tag\e[0m"
    sudo docker rm -f $(sudo docker ps --all --no-trunc | grep "Exit 0" | awk '{print $1,$2}' | grep -v ":" | awk '{print $1}')
fi

# Remove unused images
IMAGE_IDS_ALL=$(sudo docker images --all --quiet --no-trunc)
CONTAINER_IDS_ALL=$(sudo docker ps --all --quiet --no-trunc)
IMAGE_IDS_ALL_USED=""
for CONTAINER_ID in ${CONTAINER_IDS_ALL}; do
    IMAGE_ID_USED=$(sudo docker inspect --format='{{.Image}}' "$CONTAINER_ID")
    IMAGE_IDS_ALL_USED=$(echo -e "${IMAGE_IDS_ALL_USED}\n${IMAGE_ID_USED}\n$(sudo docker history --quiet --no-trunc "${IMAGE_ID_USED}")")
done
IMAGE_IDS_ALL_UNUSED=$(comm -23 <(echo "${IMAGE_IDS_ALL}" | sort -u) <(echo "${IMAGE_IDS_ALL_USED}" | sort -u))
if test -n "${IMAGE_IDS_ALL_UNUSED}"; then
    echo -e "\e[93mRemove images not used by any containers\e[0m"
    HISTORY_AND_IMAGE_IDS=""
    for IMAGE_ID_UNUSED in ${IMAGE_IDS_ALL_UNUSED}; do
        HISTORY_AND_IMAGE_IDS=$(echo -e "${HISTORY_AND_IMAGE_IDS}\n$(sudo docker history --quiet --no-trunc "${IMAGE_ID_UNUSED}" | wc -l) ${IMAGE_ID_UNUSED}")
    done
    IMAGE_IDS_ALL_UNUSED="$(echo "${HISTORY_AND_IMAGE_IDS}" | sort --unique --reverse | awk '{print $2}')"
    for IMAGE_ID_UNUSED in ${IMAGE_IDS_ALL_UNUSED}; do
        if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_UNUSED}")"; then
            sudo docker rmi --force "${IMAGE_ID_UNUSED}"
        fi
    done
fi

# Remove container directories
if test -d "/var/lib/docker/containers"; then
    CONTAINERS_DIRECTORIES=$(sudo find /var/lib/docker/containers -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -u | grep -E "^[0-9a-f]{64}$")
    CONTAINERS_USED=$(sudo docker ps --all --quiet --no-trunc | sort -u)
    CONTAINERS_DIRECTORIES_TO_DELETE=$(comm -23 <(echo -e "${CONTAINERS_DIRECTORIES}" | sort -u) <(echo -e "${CONTAINERS_USED}" | sort -u))
    if test -n "${CONTAINERS_DIRECTORIES_TO_DELETE}"; then
        echo -e "\e[93mRemove unused container directories\e[0m"
        for CONTAINERS_DIRECTORY_TO_DELETE in ${CONTAINERS_DIRECTORIES_TO_DELETE}; do
            sudo rm -rf "/var/lib/docker/containers/${CONTAINERS_DIRECTORY_TO_DELETE}"
        done
    fi
fi

# Remove volumes directories
if test -d "/var/lib/docker/volumes"; then
    VOLUMES_DIRECTORIES=$(sudo find /var/lib/docker/volumes -maxdepth 1 -mindepth 1 -type d -printf '%p\n' | sort -u | grep -E "/[0-9a-f]{64}$")
    VOLUMES_USED=$(sudo docker inspect --format="$(echo '{{range $p, $conf := .Volumes}}{{if $conf}}{{$conf}}{{end}}\n{{end}}' | sed 's/\\n/\n/g')" $(sudo docker ps --all --quiet) | sort -u | grep -v "^$")
    VOLUMES_DIRECTORIES_TO_DELETE=$(comm -23 <(echo -e "${VOLUMES_DIRECTORIES}" | sort -u) <(echo -e "${VOLUMES_USED}" | sort -u))
    if test -n "${VOLUMES_DIRECTORIES_TO_DELETE}"; then
        echo -e "\e[93mRemove unused volumes directories\e[0m"
        for VOLUMES_DIRECTORY_TO_DELETE in ${VOLUMES_DIRECTORIES_TO_DELETE}; do
            sudo rm -rf "${VOLUMES_DIRECTORY_TO_DELETE}"
        done
    fi
fi

# Remove vfs directories
if test -d "/var/lib/docker/vfs/dir"; then
    VFS_DIRECTORIES=$(sudo find /var/lib/docker/vfs/dir -maxdepth 1 -mindepth 1 -type d -printf '%p\n' | sort -u | grep -E "/[0-9a-f]{64}$")
    VFS_USED=$(sudo docker inspect --format="$(echo '{{range $p, $conf := .Volumes}}{{if $conf}}{{$conf}}{{end}}\n{{end}}' | sed 's/\\n/\n/g')" $(sudo docker ps --all --quiet) | sort -u | grep -v "^$")
    VFS_DIRECTORIES_TO_DELETE=$(comm -23 <(echo -e "${VFS_DIRECTORIES}" | sort -u) <(echo -e "${VFS_USED}" | sort -u))
    if test -n "${VFS_DIRECTORIES_TO_DELETE}"; then
        echo -e "\e[93mRemove unused vfs directories\e[0m"
        for VFS_DIRECTORY_TO_DELETE in ${VFS_DIRECTORIES_TO_DELETE}; do
            sudo rm -rf "${VFS_DIRECTORY_TO_DELETE}"
        done
    fi
fi