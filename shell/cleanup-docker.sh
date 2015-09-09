#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Cleanup
# ====== ====== ====== ====== ====== ======

#CONTAINER_CREATED="$(date "+%d/%m/%Y %H:%M:%S" -d "$(sudo docker inspect --format='{{.Created}}' "${CONTAINER_ID}")")"
#IMAGE_CREATED="$(date "+%d/%m/%Y %H:%M:%S" -d "$(sudo docker inspect --format='{{.Created}}' "${IMAGE_ID}")")"

# Remove containers
echo -e "\e[93mCheck containers\e[0m"

DATETIME=$(date +"%Y/%m/%d %H:%M")

CONTAINERS_IDS="$(sudo docker ps --all --no-trunc --quiet)"
if test -z "${CONTAINERS_IDS}"; then
    echo "Geen containers gevonden"
else
    for CONTAINER_ID in ${CONTAINERS_IDS}; do
        CONTAINER_INSPECTION="$(sudo docker inspect --format "
            Name:           {{ .Name }}
            IP:             {{ .NetworkSettings.IPAddress }}
            Created:        {{ .Created }}
            StartedAt:      {{ .State.StartedAt }}
            FinishedAt:     {{ if not .State.Running }}{{ .State.FinishedAt }}{{ end }}
            Image:          {{ .Image }}
            Path:           {{ .Path }}
            Arguments:      {{ if .Args }}{{ range .Args }}{{ . }} {{ end }}{{ end }}
            State:          {{ if .State.Running }}Running{{ else }}{{ if .State.Paused }}Paused{{ else }}{{ if .State.Dead }}Dead{{ else }}Exit{{ end }}{{ end }}{{ end }}
            ExitCode:       {{ .State.ExitCode }}
            Error:          {{ .State.Error }}
            ComposeProject: {{ index .Config.Labels \"com.docker.compose.project\" }}
            ComposeService: {{ index .Config.Labels \"com.docker.compose.service\" }}
            ComposeOneOff:  {{ index .Config.Labels \"com.docker.compose.oneoff\" }}
        " "${CONTAINER_ID}")"
        CONTAINER_NAME="$(echo "${CONTAINER_INSPECTION}" | grep "^ *Name:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_IP="$(echo "${CONTAINER_INSPECTION}" | grep "^ *IP:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_CREATED="$(echo "${CONTAINER_INSPECTION}" | grep "^ *Created:" | sed "s/^[^\:]\+\: \+//" | sed -E 's/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})\s([0-9]{2})\:([0-9]{2})\:([0-9]{2})\.[0-9]+\s(.+)$/\3\/\2\/\1 \4\:\5\:\6 \7/g')"
        CONTAINER_STARTED="$(echo "${CONTAINER_INSPECTION}" | grep "^ *StartedAt:" | sed "s/^[^\:]\+\: \+//" | sed -E 's/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})\s([0-9]{2})\:([0-9]{2})\:([0-9]{2})\.[0-9]+\s(.+)$/\3\/\2\/\1 \4\:\5\:\6 \7/g')"
        CONTAINER_FINISHED="$(echo "${CONTAINER_INSPECTION}" | grep "^ *FinishedAt:" | sed "s/^[^\:]\+\: \+//" | sed -E 's/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})\s([0-9]{2})\:([0-9]{2})\:([0-9]{2})\.[0-9]+\s(.+)$/\3\/\2\/\1 \4\:\5\:\6 \7/g')"
        CONTAINER_IMAGE_ID="$(echo "${CONTAINER_INSPECTION}" | grep "^ *Image:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_IMAGE_IDS="$(sudo docker history --quiet --no-trunc ${CONTAINER_IMAGE_ID})"
        CONTAINER_DATA_CONTAINER_ID="$(sudo docker inspect --format "{{ .HostConfig.VolumesFrom }}" "${CONTAINER_ID}")"

        CONTAINER_PATH="$(echo "${CONTAINER_INSPECTION}" | grep "^ *Path:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_ARGS="$(echo "${CONTAINER_INSPECTION}" | grep "^ *Arguments:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_CONFIG_ENTRYPOINT="$(sudo docker inspect --format "{{ if .Config.Entrypoint }}{{ range .Config.Entrypoint }}{{ . }} {{ end }}{{ end }}" "${CONTAINER_ID}")"
        CONTAINER_CONFIG_CMD="$(sudo docker inspect --format "{{ if .Config.Cmd }}{{ range .Config.Cmd }}{{ . }} {{ end }}{{ end }}" "${CONTAINER_ID}")"
        CONTAINER_STATE="$(echo "${CONTAINER_INSPECTION}" | grep "^ *State:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_STATE_EXIT_CODE="$(echo "${CONTAINER_INSPECTION}" | grep "^ *ExitCode:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_STATE_ERROR="$(echo "${CONTAINER_INSPECTION}" | grep "^ *Error:" | sed "s/^[^\:]\+\: \+//")"

        CONTAINER_VOLUMES="$(sudo docker inspect --format='{{range $v, $h := .Volumes}}{{$v}} -> {{$h}}  {{end}}' "${CONTAINER_ID}")"
        #CONTAINER_VOLUMES="$(sudo docker inspect --format "{{ .Volumes }}" "${CONTAINER_ID}")"
        #CONTAINER_VOLUMES_RW="$(sudo docker inspect --format "{{ .VolumesRW }}" "${CONTAINER_ID}")"
        #CONTAINER_CONFIG_VOLUMES="$(sudo docker inspect --format "{{ .Config.Volumes }}" "${CONTAINER_ID}")"
        CONTAINER_PORTS="$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{if $conf}}{{(index $conf 0).HostPort}}{{else}}{{$conf}}{{end}}  {{end}}' "${CONTAINER_ID}")"

#        CONTAINER_LOGS="$(sudo docker logs "${CONTAINER_ID}")"

        CONTAINER_DOCKER_COMPOSE_PROJECT="$(echo "${CONTAINER_INSPECTION}" | grep "^ *ComposeProject:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_DOCKER_COMPOSE_SERVICE="$(echo "${CONTAINER_INSPECTION}" | grep "^ *ComposeService:" | sed "s/^[^\:]\+\: \+//")"
        CONTAINER_DOCKER_COMPOSE_ONEOFF="$(echo "${CONTAINER_INSPECTION}" | grep "^ *ComposeOneOff:" | sed "s/^[^\:]\+\: \+//")"

#        echo "Container id  : ${CONTAINER_ID}"
#        echo "Name          : ${CONTAINER_NAME}"
#        echo "Project       : ${CONTAINER_DOCKER_COMPOSE_PROJECT}"
#        echo "Service       : ${CONTAINER_DOCKER_COMPOSE_SERVICE}"
#        echo "RunOneOff     : ${CONTAINER_DOCKER_COMPOSE_ONEOFF}"
#        echo "Image id      : ${CONTAINER_IMAGE_ID}"
#        echo "Data id       : ${CONTAINER_DATA_CONTAINER_ID}"
#        echo "Command       : ${CONTAINER_CONFIG_ENTRYPOINT}${CONTAINER_CONFIG_CMD}"
#        echo "Created       : ${CONTAINER_CREATED}"
#        echo "Started       : ${CONTAINER_STARTED}"
#        echo "State         : ${CONTAINER_STATE} ${CONTAINER_STATE_EXIT_CODE}"
#        echo "Error         : ${CONTAINER_STATE_ERROR}"
#        echo "Finished      : ${CONTAINER_FINISHED}"
#        echo "Run with      : ${CONTAINER_PATH} ${CONTAINER_ARGS}"
#        echo "IP            : ${CONTAINER_IP}"


        REMOVE=false

        # Remove dead container
        if test "Dead" == "${CONTAINER_STATE}"; then
            echo -e "\e[93mMark container \"${CONTAINER_ID}\" for removal: dead container\e[0m"
            REMOVE=true
        fi

        # Remove exited container not with exit 0
        if test "Exit" == "${CONTAINER_STATE}" && test "0" != "${CONTAINER_STATE_EXIT_CODE}"; then
            echo -e "\e[93mMark container \"${CONTAINER_ID}\" for removal: exited container with exit code ${CONTAINER_STATE_EXIT_CODE}\e[0m"
            REMOVE=true
        fi

        # Remove exited container without a tag
        if test "Exit" == "${CONTAINER_STATE}" && test -z "${CONTAINER_NAME}"; then
            echo -e "\e[93mMark container \"${CONTAINER_ID}\" for removal: exited container without a name\e[0m"
            REMOVE=true
        fi

        # Remove compose container oneoff
        if test "True" == "${CONTAINER_DOCKER_COMPOSE_ONEOFF}"; then
            echo -e "\e[93mMark container \"${CONTAINER_ID}\" for removal: docker-compose only run container\e[0m"
            REMOVE=true
        fi

        # Remove container with missing image
        if test -z "${CONTAINER_IMAGE_ID}"; then
            echo -e "\e[93mMark container \"${CONTAINER_ID}\" for removal: missing image\e[0m"
            REMOVE=true
        fi

        # Remove container
        if test true == ${REMOVE}; then
            sudo docker rm -f "${CONTAINER_ID}"
        fi

        echo " "

    done
fi

# Remove images
echo -e "\e[93mCheck images\e[0m"

#IMAGES_IDS="$(sudo docker images --all --no-trunc --quiet)"
#CONTAINERS_IDS="$(sudo docker ps --all --no-trunc --quiet)"
#if test -z "${IMAGES_IDS}"; then
#    echo "Geen images gevonden"
#else
#    IMAGES_IDS_FROM_CONTAINERS=$(sudo docker inspect --format='{{ .Id }}' ${CONTAINERS_IDS})
#    echo "${IMAGES_IDS_FROM_CONTAINERS}"
#
#    for IMAGE_ID_USED in ${IMAGES_IDS_FROM_CONTAINERS}; do
#        if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_USED}")"; then
#            IMAGES_IDS_FROM_CONTAINERS=$(echo -e "${IMAGES_IDS_FROM_CONTAINERS}\n${IMAGE_ID_USED}\n$(sudo docker history --quiet --no-trunc ${IMAGE_ID_USED})")
#        fi
#    done
#    echo "---"
#    echo "${IMAGES_IDS_FROM_CONTAINERS}"
#    IMAGES_IDS_UNUSED=$(comm -23 <(echo "${IMAGES_IDS}" | sort -u) <(echo "${IMAGES_IDS_FROM_CONTAINERS}" | sort -u))
#    echo "---"
#    echo "${IMAGES_IDS_UNUSED}"
##
##
##    if test -n "${IMAGES_IDS_UNUSED}"; then
##        HISTORY_AND_IMAGE_IDS=""
##        for IMAGE_ID_UNUSED in ${IMAGES_IDS_UNUSED}; do
##            echo "${IMAGE_ID_UNUSED} removing"
###            docker rmi $(docker history --quiet --no-trunc "${IMAGE_ID_UNUSED}")
##    #        HISTORY_AND_IMAGE_IDS=$(echo -e "${HISTORY_AND_IMAGE_IDS}\n$(sudo docker history --quiet --no-trunc "${IMAGE_ID_UNUSED}" | wc -l) ${IMAGE_ID_UNUSED}")
##        done
##    #    IMAGES_IDS_UNUSED="$(echo "${HISTORY_AND_IMAGE_IDS}" | sort --unique --reverse | awk '{print $2}')"
##    #    for IMAGE_ID_UNUSED in ${IMAGES_IDS_UNUSED}; do
##    #        if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_UNUSED}")"; then
##    #            echo -e "\e[93mRemove image \"${IMAGE_ID_UNUSED}\" (not used by any container)\e[0m"
##    #            sudo docker rmi --force "${IMAGE_ID_UNUSED}"
##    #        fi
##    #    done
##    fi
#
#    echo " "
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