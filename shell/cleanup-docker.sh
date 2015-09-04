#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker containers
# ====== ====== ====== ====== ====== ======

# Remove containers
echo -e "\e[93mCheck containers\e[0m"

# Remove containers with missing image
#CONTAINER_IDS_ALL=$(sudo docker ps --all --quiet --no-trunc)
#for CONTAINER_ID in ${CONTAINER_IDS_ALL}; do
#    IMAGE_ID_CHECK=$(sudo docker inspect --format='{{.Image}}' "${CONTAINER_ID}")
#    if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_CHECK}")"; then
#        echo -e "\e[93mRemove container \"${CONTAINER_ID}\" (missing image)\e[0m"
#        sudo docker rm -f "${CONTAINER_ID}"
#    fi
#done

# Remove dead containers
CONTAINERS_IDS_DEAD="$(sudo docker ps --all --no-trunc | grep " Dead " | awk '{print $1}')"
if test -n "${CONTAINERS_IDS_DEAD}"; then
    for CONTAINER_ID_DEAD in ${CONTAINERS_IDS_DEAD}; do
        echo -e "\e[93mRemove container \"${CONTAINER_ID_DEAD}\" (dead container)\e[0m"
        sudo docker rm -f "${CONTAINER_ID_DEAD}"
    done
fi

# Remove exited containers not with exit 0
CONTAINERS_IDS_EXITED="$(sudo docker ps --all --no-trunc | grep "Exited " | grep -v "Exited (0)" | awk '{print $1}')"
if test -n "${CONTAINERS_IDS_EXITED}"; then
    for CONTAINER_ID_EXITED in ${CONTAINERS_IDS_EXITED}; do
        echo -e "\e[93mRemove container \"${CONTAINER_ID_EXITED}\" (exited container, not with exit code 0)\e[0m"
        sudo docker rm -f "${CONTAINER_ID_EXITED}"
    done
fi

# Remove exited containers without a tag
CONTAINERS_IDS_UNTAGGED="$(sudo docker ps --all --no-trunc | grep "Exited (0)" | awk '{print $1,$2}' | grep -v ":" | awk '{print $1}')"
if test -n "${CONTAINERS_IDS_UNTAGGED}"; then
    for CONTAINER_ID_UNTAGGED in ${CONTAINERS_IDS_UNTAGGED}; do
        echo -e "\e[93mRemove container \"${CONTAINER_ID_UNTAGGED}\" (exited container, without a tag)\e[0m"
        sudo docker rm -f "${CONTAINER_ID_UNTAGGED}"
    done
fi

# Remove unused images
echo -e "\e[93mCheck images\e[0m"
#IMAGE_IDS_ALL=$(sudo docker images --all --quiet --no-trunc)
#CONTAINER_IDS_ALL=$(sudo docker ps --all --quiet --no-trunc)
#IMAGE_IDS_ALL_USED=""
#for CONTAINER_ID in ${CONTAINER_IDS_ALL}; do
#    IMAGE_ID_USED=$(sudo docker inspect --format='{{.Image}}' "${CONTAINER_ID}")
#    if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_USED}")"; then
#        echo "Container ${CONTAINER_ID} uses image ${IMAGE_ID_USED}"
#        IMAGE_IDS_ALL_USED=$(echo -e "${IMAGE_IDS_ALL_USED}\n${IMAGE_ID_USED}\n$(sudo docker history --quiet --no-trunc "${IMAGE_ID_USED}")")
#    fi
#done
#IMAGE_IDS_ALL_UNUSED=$(comm -23 <(echo "${IMAGE_IDS_ALL}" | sort -u) <(echo "${IMAGE_IDS_ALL_USED}" | sort -u))
#if test -n "${IMAGE_IDS_ALL_UNUSED}"; then
#    HISTORY_AND_IMAGE_IDS=""
#    for IMAGE_ID_UNUSED in ${IMAGE_IDS_ALL_UNUSED}; do
#        HISTORY_AND_IMAGE_IDS=$(echo -e "${HISTORY_AND_IMAGE_IDS}\n$(sudo docker history --quiet --no-trunc "${IMAGE_ID_UNUSED}" | wc -l) ${IMAGE_ID_UNUSED}")
#    done
#    IMAGE_IDS_ALL_UNUSED="$(echo "${HISTORY_AND_IMAGE_IDS}" | sort --unique --reverse | awk '{print $2}')"
#    for IMAGE_ID_UNUSED in ${IMAGE_IDS_ALL_UNUSED}; do
#        if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_UNUSED}")"; then
#            echo -e "\e[93mRemove image \"${IMAGE_ID_UNUSED}\" (not used by any container)\e[0m"
#            sudo docker rmi --force "${IMAGE_ID_UNUSED}"
#        fi
#    done
#fi

# Remove container directories
echo -e "\e[93mCheck directories\e[0m"
if sudo test -d "/var/lib/docker/containers"; then
    CONTAINERS_DIRECTORIES=$(sudo find /var/lib/docker/containers -maxdepth 1 -mindepth 1 -type d -printf '%f\n' | sort -u | grep -E "^[0-9a-f]{64}$")
    if test -n "${CONTAINERS_DIRECTORIES}"; then
        echo -e "\e[96mContainer directories:\e[0m"
        echo "${CONTAINERS_DIRECTORIES}"
    fi
    CONTAINERS_USED=""
    if test -n "$(sudo docker ps --all --quiet --no-trunc)"; then
        CONTAINERS_USED=$(sudo docker ps --all --quiet --no-trunc | grep -v " DEAD " | sort -u)
        if test -n "${CONTAINERS_USED}"; then
            echo -e "\e[96mContainers used:\e[0m"
            echo "${CONTAINERS_USED}"
        fi
    fi
    CONTAINERS_DIRECTORIES_TO_DELETE=$(comm -23 <(echo -e "${CONTAINERS_DIRECTORIES}" | sort -u) <(echo -e "${CONTAINERS_USED}" | sort -u))
    if test -n "${CONTAINERS_DIRECTORIES_TO_DELETE}"; then
        echo -e "\e[96mContainer directories to delete:\e[0m"
        echo "${CONTAINERS_DIRECTORIES_TO_DELETE}"
        for CONTAINER_DIRECTORY_TO_DELETE in ${CONTAINERS_DIRECTORIES_TO_DELETE}; do
            echo -e "\e[93mRemove unused container directory \"/var/lib/docker/containers/${CONTAINER_DIRECTORY_TO_DELETE}\"\e[0m"
            sudo rm -rf "/var/lib/docker/containers/${CONTAINER_DIRECTORY_TO_DELETE}"
        done
    fi
fi

# Remove volumes directories
#if sudo test -d "/var/lib/docker/volumes"; then
#    VOLUMES_DIRECTORIES=$(sudo find /var/lib/docker/volumes -maxdepth 1 -mindepth 1 -type d -printf '%p\n' | sort -u | grep -E "/[0-9a-f]{64}$")
#    if test -n "${VOLUMES_DIRECTORIES}"; then
#        echo -e "\e[96mVolume directories:\e[0m"
#        echo "${VOLUMES_DIRECTORIES}"
#    fi
#    VOLUMES_USED=""
#    if test -n "$(sudo docker ps --all --quiet --no-trunc)"; then
#        VOLUMES_USED=$(sudo docker inspect --format="$(echo '{{range $p, $conf := .Volumes}}{{if $conf}}{{$conf}}{{end}}\n{{end}}' | sed 's/\\n/\n/g')" $(sudo docker ps --all --quiet --no-trunc) | sort -u | grep -v "^$")
#        if test -n "${VOLUMES_USED}"; then
#            echo -e "\e[96mVolumes used:\e[0m"
#            echo "${VOLUMES_USED}"
#        fi
#    fi
#    VOLUMES_DIRECTORIES_TO_DELETE=$(comm -23 <(echo -e "${VOLUMES_DIRECTORIES}" | sort -u) <(echo -e "${VOLUMES_USED}" | sort -u))
#    if test -n "${VOLUMES_DIRECTORIES_TO_DELETE}"; then
#        echo -e "\e[96mVolume directories to delete:\e[0m"
#        echo "${VOLUMES_DIRECTORIES_TO_DELETE}"
#        for VOLUME_DIRECTORY_TO_DELETE in ${VOLUMES_DIRECTORIES_TO_DELETE}; do
#            echo -e "\e[93mRemove unused volume directory \"${VOLUME_DIRECTORY_TO_DELETE}\"\e[0m"
#            sudo rm -rf "${VOLUME_DIRECTORY_TO_DELETE}"
#        done
#    fi
#fi

# Remove vfs directories
#if sudo test -d "/var/lib/docker/vfs/dir"; then
#    VFS_DIRECTORIES=$(sudo find /var/lib/docker/vfs/dir -maxdepth 1 -mindepth 1 -type d -printf '%p\n' | sort -u | grep -E "/[0-9a-f]{64}$")
#    if test -n "${VFS_DIRECTORIES}"; then
#        echo -e "\e[96mVfs directories:\e[0m"
#        echo "${VFS_DIRECTORIES}"
#    fi
#    VFS_USED=""
#    if test -n "$(sudo docker ps --all --quiet --no-trunc)"; then
#        VFS_USED=$(sudo docker inspect --format="$(echo '{{range $p, $conf := .Volumes}}{{if $conf}}{{$conf}}{{end}}\n{{end}}' | sed 's/\\n/\n/g')" $(sudo docker ps --all --quiet --no-trunc) | sort -u | grep -v "^$")
#        if test -n "${VFS_USED}"; then
#            echo -e "\e[96mVfs directories used:\e[0m"
#            echo "${VFS_USED}"
#        fi
#    fi
#    VFS_DIRECTORIES_TO_DELETE=$(comm -23 <(echo -e "${VFS_DIRECTORIES}" | sort -u) <(echo -e "${VFS_USED}" | sort -u))
#    if test -n "${VFS_DIRECTORIES_TO_DELETE}"; then
#        echo -e "\e[96mVfs directories to delete:\e[0m"
#        echo "${VFS_DIRECTORIES_TO_DELETE}"
#        for VFS_DIRECTORY_TO_DELETE in ${VFS_DIRECTORIES_TO_DELETE}; do
#            echo -e "\e[93mRemove unused vfs directory \"${VFS_DIRECTORY_TO_DELETE}\"\e[0m"
#            sudo rm -rf "${VFS_DIRECTORY_TO_DELETE}"
#        done
#    fi
#fi