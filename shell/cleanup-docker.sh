#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker containers
# ====== ====== ====== ====== ====== ======

# TODO remove containers with images that don't exist anymore
# TODO check what docker is doing when using history or --all

#CONTAINER_CREATED="$(date "+%d/%m/%Y %H:%M:%S" -d "$(sudo docker inspect --format='{{.Created}}' "${CONTAINER_ID}")")"
#IMAGE_ID=$(sudo docker inspect --format='{{.Image}}' "${CONTAINER_ID}")
#IMAGE_CREATED="$(date "+%d/%m/%Y %H:%M:%S" -d "$(sudo docker inspect --format='{{.Created}}' "${IMAGE_ID}")")"
#CONTAINER_ID_RUNNING=""
#if test -n "$(sudo docker ps --quiet --no-trunc)"; then
#    CONTAINER_ID_RUNNING=$(sudo docker inspect --format='{{.Name}} {{.Id}}' $(sudo docker ps --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2}')
#fi
#if test "[true] 0" = "$(sudo docker inspect --format='{{.Name}} {{.Config.Cmd}} {{.State.ExitCode}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2, $3}')"; then
#    echo -e "\e[92mdocker data container '${CONTAINER_NAME}'\e[0m"
#    echo -e "\e[92m- cid:     ${CONTAINER_ID}, created ${CONTAINER_CREATED}\e[0m"
#    echo -e "\e[92m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
#    PROJECT_VOLUMES=$(sudo docker inspect --format='{{range $v, $h := .Volumes}}{{$v}} -> {{$h}}  {{end}}' "${CONTAINER_ID}")
#    if test -n "${PROJECT_VOLUMES}"; then
#        echo -e "\e[92m- volumes: ${PROJECT_VOLUMES}\e[0m"
#    fi
#elif test -z "${CONTAINER_ID_RUNNING}"; then
#    echo -e "\e[91mdocker container '${CONTAINER_NAME}' not running\e[0m"
#    echo -e "\e[91m- cid:     ${CONTAINER_ID}, created ${CONTAINER_CREATED}\e[0m"
#    echo -e "\e[91m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
#else
#    PROJECT_IP=$(sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' "${CONTAINER_ID_RUNNING}")
#    if test -z "${PROJECT_IP}"; then
#        echo -e "\e[91mdocker container '${CONTAINER_NAME}' not reachable\e[0m"
#        echo -e "\e[91m- cid:     ${CONTAINER_ID_RUNNING}, created ${CONTAINER_CREATED}\e[0m"
#        echo -e "\e[91m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
#    else
#        echo -e "\e[92mdocker container '${CONTAINER_NAME}' on ${PROJECT_IP}\e[0m"
#        echo -e "\e[92m- cid:     ${CONTAINER_ID_RUNNING}, created ${CONTAINER_CREATED}\e[0m"
#        echo -e "\e[92m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
#        PROJECT_PORTS=$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{if $conf}}{{(index $conf 0).HostPort}}{{else}}{{$conf}}{{end}}  {{end}}' "${CONTAINER_ID_RUNNING}")
#        if test -n "${PROJECT_PORTS}"; then
#            echo -e "\e[92m- ports:   ${PROJECT_PORTS}\e[0m"
#        fi
#        PROJECT_VOLUMES=$(sudo docker inspect --format='{{range $v, $h := .Volumes}}{{$v}} -> {{$h}}  {{end}}' "${CONTAINER_ID}")
#        if test -n "${PROJECT_VOLUMES}"; then
#            echo -e "\e[92m- volumes: ${PROJECT_VOLUMES}\e[0m"
#        fi
#    fi
#fi

# DOCKER LOGS REPORTING
#DATETIME=$(date +"%Y/%m/%d %H:%M")
#echo "--- ${DATETIME} ---" >> "${LOG_DIR}/docker_${CONTAINER_NAME}.log"
#sudo docker logs "${CONTAINER_ID}" >> "${LOG_DIR}/docker_${CONTAINER_NAME}.log"











# Remove containers
echo -e "\e[93mCheck containers\e[0m"

CONTAINER_IDS="$(sudo docker ps --all --no-trunc --quiet)"


if test -z "${CONTAINER_IDS}"; then
    echo "Geen containers gevonden" # TODO
else
    for CONTAINER_ID in ${CONTAINER_IDS}; do
        CONTAINER_NAME="$(sudo docker inspect --format "{{ .Name }}" "${CONTAINER_ID}")"
        CONTAINER_IP="$(sudo docker inspect --format "{{ .NetworkSettings.IPAddress }}" "${CONTAINER_ID}")"
        CONTAINER_CREATED="$(sudo docker inspect --format "{{ .Created }}" "${CONTAINER_ID}"  | sed -E 's/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})\s([0-9]{2})\:([0-9]{2})\:([0-9]{2})\.[0-9]+\s(.+)$/\3\/\2\/\1 \4\:\5\:\6 \7/g')"
        CONTAINER_STARTED="$(sudo docker inspect --format "{{ .State.StartedAt }}" "${CONTAINER_ID}"  | sed -E 's/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})\s([0-9]{2})\:([0-9]{2})\:([0-9]{2})\.[0-9]+\s(.+)$/\3\/\2\/\1 \4\:\5\:\6 \7/g')"
        CONTAINER_FINISHED="$(sudo docker inspect --format "{{ if not .State.Running }}{{ .State.FinishedAt }}{{ end }}" "${CONTAINER_ID}"  | sed -E 's/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})\s([0-9]{2})\:([0-9]{2})\:([0-9]{2})\.[0-9]+\s(.+)$/\3\/\2\/\1 \4\:\5\:\6 \7/g')"
        CONTAINER_IMAGE_ID="$(sudo docker inspect --format "{{ .Image }}" "${CONTAINER_ID}")"
        CONTAINER_IMAGE_IDS="$(sudo docker history --quiet --no-trunc ${CONTAINER_IMAGE_ID})"

        CONTAINER_PATH="$(sudo docker inspect --format "{{ .Path }}" "${CONTAINER_ID}")"
        CONTAINER_ARGS="$(sudo docker inspect --format "{{ if .Args }}{{ range .Args }}{{ . }} {{ end }}{{ end }}" "${CONTAINER_ID}")"
        CONTAINER_CONFIG_ENTRYPOINT="$(sudo docker inspect --format "{{ if .Config.Entrypoint }}{{ range .Config.Entrypoint }}{{ . }} {{ end }}{{ end }}" "${CONTAINER_ID}")"
        CONTAINER_CONFIG_CMD="$(sudo docker inspect --format "{{ if .Config.Cmd }}{{ range .Config.Cmd }}{{ . }} {{ end }}{{ end }}" "${CONTAINER_ID}")"
        CONTAINER_STATE="$(sudo docker inspect --format "{{ if .State.Running }}Running{{ else }}{{ if .State.Paused }}Paused{{ else }}{{ if .State.Dead }}Dead{{ else }}Exit{{ end }}{{ end }}{{ end }}" "${CONTAINER_ID}")"
        CONTAINER_STATE_EXIT_CODE="$(sudo docker inspect --format "{{ .State.ExitCode }}" "${CONTAINER_ID}")"
        CONTAINER_STATE_ERROR="$(sudo docker inspect --format "{{ .State.Error }}" "${CONTAINER_ID}")"

        CONTAINER_DOCKER_COMPOSE_PROJECT="$(sudo docker inspect --format "{{ index .Config.Labels \"com.docker.compose.project\" }}" "${CONTAINER_ID}")"
        CONTAINER_DOCKER_COMPOSE_SERVICE="$(sudo docker inspect --format "{{ index .Config.Labels \"com.docker.compose.service\" }}" "${CONTAINER_ID}")"

        echo "Container id: ${CONTAINER_ID}"
        echo "Name        : ${CONTAINER_NAME}"
        echo "Image id    : ${CONTAINER_IMAGE_ID}"
        echo "Command     : ${CONTAINER_CONFIG_ENTRYPOINT}${CONTAINER_CONFIG_CMD}"
        echo "Created     : ${CONTAINER_CREATED}"
        echo "Started     : ${CONTAINER_STARTED}"
        echo "State       : ${CONTAINER_STATE} ${CONTAINER_STATE_EXIT_CODE}"
        echo "Finished    : ${CONTAINER_FINISHED}"
        echo "Run with    : ${CONTAINER_PATH} ${CONTAINER_ARGS}"
        echo "IP          : ${CONTAINER_IP}"

        CONTAINER_VOLUMES="$(sudo docker inspect --format "{{ .Volumes }}" "${CONTAINER_ID}")"
        CONTAINER_VOLUMES_RW="$(sudo docker inspect --format "{{ .VolumesRW }}" "${CONTAINER_ID}")"
        CONTAINER_CONFIG_VOLUMES="$(sudo docker inspect --format "{{ .Config.Volumes }}" "${CONTAINER_ID}")"
        #.HostConfig.VolumesFrom => id van de data container

        # Remove dead containers
        if test "Dead" == "${CONTAINER_STATE}"; then
            echo -e "\e[93mRemove container \"${CONTAINER_ID}\" (dead container)\e[0m"
#           sudo docker rm -f "${CONTAINER_ID}"
        fi

        # Remove exited containers not with exit 0
        if test "Exit" == "${CONTAINER_STATE}" && "0" != "${CONTAINER_STATE_EXIT_CODE}"; then
            echo -e "\e[93mRemove container \"${CONTAINER_ID}\" (exited container with exit code ${CONTAINER_STATE_EXIT_CODE})\e[0m"
#            sudo docker rm -f "${CONTAINER_ID}"
        fi

        # Remove exited containers without a tag
        if test "Exit" == "${CONTAINER_STATE}" && -z "${CONTAINER_NAME}"; then
            echo -e "\e[93mRemove container \"${CONTAINER_ID}\" (exited container without a name)\e[0m"
#            sudo docker rm -f "${CONTAINER_ID}"
        fi

        # Remove containers with missing image
        if test -z "${CONTAINER_IMAGE_ID}"; then
            echo -e "\e[93mRemove container \"${CONTAINER_ID}\" (missing image)\e[0m"
#            sudo docker rm -f "${CONTAINER_ID}"
        fi

        echo " "
        exit

    done
fi



exit

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