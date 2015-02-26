#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker containers
# ====== ====== ====== ====== ====== ======

if test -n "${1+1}"; then
    DOCKER_CONTAINER_FILEPATHS="${1}"
else
    DOCKER_CONTAINER_FILEPATHS="$(find / -name "Dockerfile" -type f -exec dirname "{}" \; 2>/dev/null | grep -v "docker/aufs" | tr '\n' ',')"
fi

if which docker &> /dev/null; then

    IFS=',' read -ra DOCKER_CONTAINER_FILEPATHS <<< "${DOCKER_CONTAINER_FILEPATHS}"
    if test -n "${DOCKER_CONTAINER_FILEPATHS}"; then

        for CONTAINER_DIRECTORY in "${DOCKER_CONTAINER_FILEPATHS[@]}"; do

            FILENAME_RUNSCRIPT="run.sh"

            if test -f "/env/docker/containers/${CONTAINER_DIRECTORY}/${FILENAME_RUNSCRIPT}"; then

                CONTAINER_NAME="$(basename "${CONTAINER_DIRECTORY}")"

                mkdir -p "/env/docker/.docker/log"
                if test -f "/env/docker/.docker/log/${CONTAINER_DIRECTORY}.log"; then
                    rm "/env/docker/.docker/log/${CONTAINER_DIRECTORY}.log"
                fi

                if test -z "$(sudo docker ps --all --quiet --no-trunc)"; then
                    echo -e "\e[91mdocker container '${CONTAINER_NAME}' not found\e[0m"
                else
                    CONTAINER_ID=$(sudo docker inspect --format='{{.Name}} {{.Id}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2}')
                    if test -z "${CONTAINER_ID}"; then
                        echo -e "\e[91mdocker container '${CONTAINER_NAME}' not found\e[0m"
                    else
                        CONTAINER_CREATED="$(date "+%d/%m/%Y %H:%M:%S" -d "$(sudo docker inspect --format='{{.Created}}' "${CONTAINER_ID}")")"
                        IMAGE_ID=$(sudo docker inspect --format='{{.Image}}' "${CONTAINER_ID}")
                        IMAGE_CREATED="$(date "+%d/%m/%Y %H:%M:%S" -d "$(sudo docker inspect --format='{{.Created}}' "${IMAGE_ID}")")"
                        CONTAINER_ID_RUNNING=""
                        if test -n "$(sudo docker ps --quiet --no-trunc)"; then
                            CONTAINER_ID_RUNNING=$(sudo docker inspect --format='{{.Name}} {{.Id}}' $(sudo docker ps --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2}')
                        fi
                        if test "[true] 0" = "$(sudo docker inspect --format='{{.Name}} {{.Config.Cmd}} {{.State.ExitCode}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2, $3}')"; then
                            echo -e "\e[92mdocker data container '${CONTAINER_NAME}'\e[0m"
                            echo -e "\e[92m- cid:     ${CONTAINER_ID}, created ${CONTAINER_CREATED}\e[0m"
                            echo -e "\e[92m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
                            PROJECT_VOLUMES=$(sudo docker inspect --format='{{range $v, $h := .Volumes}}{{$v}} -> {{$h}}  {{end}}' "${CONTAINER_ID}")
                            if test -n "${PROJECT_VOLUMES}"; then
                                echo -e "\e[92m- volumes: ${PROJECT_VOLUMES}\e[0m"
                            fi
                        elif test -z "${CONTAINER_ID_RUNNING}"; then
                            echo -e "\e[91mdocker container '${CONTAINER_NAME}' not running\e[0m"
                            echo -e "\e[91m- cid:     ${CONTAINER_ID}, created ${CONTAINER_CREATED}\e[0m"
                            echo -e "\e[91m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
                        else
                            PROJECT_IP=$(sudo docker inspect --format='{{.NetworkSettings.IPAddress}}' "${CONTAINER_ID_RUNNING}")
                            if test -z "${PROJECT_IP}"; then
                                echo -e "\e[91mdocker container '${CONTAINER_NAME}' not reachable\e[0m"
                                echo -e "\e[91m- cid:     ${CONTAINER_ID_RUNNING}, created ${CONTAINER_CREATED}\e[0m"
                                echo -e "\e[91m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
                            else
                                echo -e "\e[92mdocker container '${CONTAINER_NAME}' on ${PROJECT_IP}\e[0m"
                                echo -e "\e[92m- cid:     ${CONTAINER_ID_RUNNING}, created ${CONTAINER_CREATED}\e[0m"
                                echo -e "\e[92m- image:   ${IMAGE_ID}, created ${IMAGE_CREATED}\e[0m"
                                PROJECT_PORTS=$(sudo docker inspect --format='{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{if $conf}}{{(index $conf 0).HostPort}}{{else}}{{$conf}}{{end}}  {{end}}' "${CONTAINER_ID_RUNNING}")
                                if test -n "${PROJECT_PORTS}"; then
                                    echo -e "\e[92m- ports:   ${PROJECT_PORTS}\e[0m"
                                fi
                                PROJECT_VOLUMES=$(sudo docker inspect --format='{{range $v, $h := .Volumes}}{{$v}} -> {{$h}}  {{end}}' "${CONTAINER_ID}")
                                if test -n "${PROJECT_VOLUMES}"; then
                                    echo -e "\e[92m- volumes: ${PROJECT_VOLUMES}\e[0m"
                                fi
                            fi
                        fi
                        DATETIME=$(date +"%Y/%m/%d %H:%M")
                        echo "--- ${DATETIME} ---" >> "/env/docker/.docker/log/${CONTAINER_DIRECTORY}.log"
                        sudo docker logs "${CONTAINER_ID}" >> "/env/docker/.docker/log/${CONTAINER_DIRECTORY}.log"
                    fi
                fi
                echo " "

            fi

        done

    fi

fi