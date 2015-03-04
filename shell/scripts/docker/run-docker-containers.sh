#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker containers
# ====== ====== ====== ====== ====== ======

if test -n "${1+1}"; then
    DOCKER_CONTAINER_FILEPATHS="${1}"
fi

if which docker &> /dev/null; then

    REPOSITORY="devmachine"

    IFS=',' read -ra DOCKER_CONTAINER_FILEPATHS <<< "${DOCKER_CONTAINER_FILEPATHS}"
    if test -n "${DOCKER_CONTAINER_FILEPATHS}"; then

        BUILDSCRIPT_FILENAME="build.sh"
        RUNSCRIPT_FILENAME="run.sh"

        for CONTAINER_DIRECTORY in "${DOCKER_CONTAINER_FILEPATHS[@]}"; do

            CONTAINER_NAME="$(basename "${CONTAINER_DIRECTORY}")"

            # Create tag
            TAG="$(find "/env/docker/containers/${CONTAINER_DIRECTORY}" -not -path "/env/docker/containers/${CONTAINER_DIRECTORY}/data/*" -type f \( -exec cat {} \; \) | sed ':a;N;$!ba;s/[\ \n]//g' | sha1sum | sed 's/[^a-z0-9]*//g')"

            # Get image
            IMAGE_ID_TAGGED="$(sudo docker images --all --no-trunc | grep "^devmachine " | awk '{print $3, $2}' | grep " ${CONTAINER_NAME}-${TAG}-image" | awk '{print $1}')"

            # Create image if not found
            if test -z "${IMAGE_ID_TAGGED}"; then
                # Check build script
                if test -f "/env/docker/containers/${CONTAINER_DIRECTORY}/${BUILDSCRIPT_FILENAME}"; then
                    # Build new image
                    echo -e "\e[93mBuild new image for container '${CONTAINER_NAME}'\e[0m"
                    exec 5>&1
                    BUILD_OUTPUT=$(source "/env/docker/containers/${CONTAINER_DIRECTORY}/${BUILDSCRIPT_FILENAME}" | tee >(cat - >&5))
                    IMAGE_ID_CREATED="$(echo "${BUILD_OUTPUT}" | sed "s/\x1B\[[0-9;]*[a-zA-Z]//g" | grep "Successfully built " | tr -d '\011\012\015' | sed -r "s/Successfully built ([a-z0-9]+)/\1/")"
                    IMAGE_ID_CREATED="$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_CREATED}" | uniq)"
                    if test -n "${IMAGE_ID_CREATED}"; then
                        echo -e "\e[93mTag new image for container '${CONTAINER_NAME}'\e[0m"
                        sudo docker tag --force "${IMAGE_ID_CREATED}" "${REPOSITORY}:${CONTAINER_NAME}-image"
                        echo "${REPOSITORY}:${CONTAINER_NAME}-image"
                        sudo docker tag --force "${IMAGE_ID_CREATED}" "${REPOSITORY}:${CONTAINER_NAME}-${TAG}-image"
                        echo "${REPOSITORY}:${CONTAINER_NAME}-${TAG}-image"
                        IMAGE_ID_TAGGED="$(sudo docker inspect --format="{{.Id}}" "${REPOSITORY}:${CONTAINER_NAME}-${TAG}-image")"
                    fi
                fi #/ check build script
            fi #/ has no tagged image

            # Gather old images tagged with the name (direct)
            IMAGE_IDS_OLD="$(sudo docker images --all --no-trunc | grep "^devmachine " | awk '{print $3, $2}' | grep " ${CONTAINER_NAME}-[^\-]*-image" | grep -v " ${CONTAINER_NAME}-${TAG}-image" | awk '{print $1}')"
            if test -n "${IMAGE_ID_TAGGED}"; then
                IMAGE_IDS_OLD="$(echo ${IMAGE_IDS_OLD} | grep -v "${IMAGE_ID_TAGGED}")"
            fi

            # Gather old images that were used to create containers with the name (indirect)
            if test -n "${IMAGE_ID_TAGGED}"; then
                if test -n "$(sudo docker ps --all --quiet --no-trunc)"; then
                    IMAGE_IDS_OLD_USED="$(sudo docker inspect --format='{{.Name}} {{.Image}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2}' | grep -v "${IMAGE_ID_TAGGED}")"
                    if test -n "${IMAGE_IDS_OLD_USED}"; then
                        if test -z "${IMAGE_IDS_OLD}"; then
                            IMAGE_IDS_OLD="$(echo -e "${IMAGE_IDS_OLD_USED}")"
                        else
                            IMAGE_IDS_OLD="$(echo -e "${IMAGE_IDS_OLD}\n${IMAGE_IDS_OLD_USED}")"
                        fi
                    fi
                fi
            fi

            # Remove old images (and the containers that might be locking them)
            # TIP: we wait to remove until after the new build, to be able to use the image cache
            if test -n "${IMAGE_IDS_OLD}"; then
                CONTAINER_IDS_ALL=$(sudo docker ps --all --quiet --no-trunc)
                if test -n "${CONTAINER_IDS_ALL}"; then
                    CONTAINER_IDS_LOCKING=""
                    for IMAGE_ID in ${IMAGE_IDS_OLD}; do
                        for CONTAINER_ID_LOCKING in ${CONTAINER_IDS_ALL}; do
                            IMAGE_ID_USED=$(sudo docker inspect --format='{{.Image}}' "${CONTAINER_ID_LOCKING}")
                            if test "${IMAGE_ID}" = "${IMAGE_ID_USED}"; then
                                CONTAINER_IDS_LOCKING=$(echo -e "${CONTAINER_IDS_LOCKING}\n${CONTAINER_ID_LOCKING}")
                            fi
                            COUNTER=0
                            while test "<no value>" != "${IMAGE_ID_USED}" && test ${COUNTER} -lt 99; do
                                COUNTER=$[COUNTER+1]
                                IMAGE_ID_USED=$(sudo docker inspect --format='{{.parent}}' "${IMAGE_ID_USED}")
                                if test "${IMAGE_ID_USED}" = "${IMAGE_ID}"; then
                                    CONTAINER_IDS_LOCKING=$(echo -e "${CONTAINER_IDS_LOCKING}\n${CONTAINER_ID_LOCKING}")
                                fi
                            done
                        done
                    done
                    if test -n "${CONTAINER_IDS_LOCKING}"; then
                        echo -e "\e[93mRemove old containers for container '${CONTAINER_NAME}'\e[0m"
                        for CONTAINER_ID in ${CONTAINER_IDS_LOCKING}; do
                            if test -n "$(sudo docker ps --quiet --no-trunc | grep "${CONTAINER_ID}")"; then
                                sudo docker stop "${CONTAINER_ID}"
                            fi
                            if test -n "$(sudo docker ps --all --quiet --no-trunc | grep "${CONTAINER_ID}")"; then
                                sudo docker rm --force "${CONTAINER_ID}"
                            fi
                        done
                    fi
                fi
                echo -e "\e[93mRemove old images for container '${CONTAINER_NAME}'\e[0m"
                for IMAGE_ID in ${IMAGE_IDS_OLD}; do
                    if test -n "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID}")"; then
                        sudo docker rmi --force "${IMAGE_ID}" # TODO never delete the newly created image
                    fi
                done
            fi #/ has old images

            # Save tag
            mkdir -p "/env/.docker/"
            echo "${TAG}" > "/env/.docker/${CONTAINER_NAME}.version"

            # Remove containers based on images that are not present anymore
            if test -n "$(sudo docker ps --all --quiet --no-trunc)"; then
                IMAGE_ID_USED="$(sudo docker inspect --format='{{.Name}} {{.Image}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2}')"
                if test -n "${IMAGE_ID_USED}"; then
                    if test -z "$(sudo docker images --all --quiet --no-trunc | grep "${IMAGE_ID_USED}")"; then
                        CONTAINER_IDS_OLD="$(sudo docker inspect --format='{{.Name}} {{.Image}} {{.Id}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | grep -v " ${IMAGE_ID_USED} " | awk '{print $3}')"
                        if test -n "${CONTAINER_IDS_OLD}"; then
                            echo -e "\e[93mRemove old containers for container '${CONTAINER_NAME}'\e[0m"
                            for CONTAINER_ID in ${CONTAINER_IDS_OLD}; do
                                if test -n "$(sudo docker ps --quiet --no-trunc | grep "${CONTAINER_ID}")"; then
                                    sudo docker stop "${CONTAINER_ID}"
                                fi
                                if test -n "$(sudo docker ps --all --quiet --no-trunc | grep "${CONTAINER_ID}")"; then
                                    sudo docker rm --force "${CONTAINER_ID}"
                                fi
                            done
                        fi
                    fi
                fi
            fi

            # Get container
            CONTAINER_ID=""
            if test -n "$(sudo docker ps --all --quiet --no-trunc)"; then
                CONTAINER_ID="$(sudo docker inspect --format='{{.Name}} {{.Id}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2}')"
            fi

            # Restart container, or run container if not found
            if test -z "${CONTAINER_ID}"; then
                if test -f "/env/docker/containers/${CONTAINER_DIRECTORY}/${RUNSCRIPT_FILENAME}"; then
                    echo -e "\e[93mRun container '${CONTAINER_NAME}'\e[0m"
                    source "/env/docker/containers/${CONTAINER_DIRECTORY}/${RUNSCRIPT_FILENAME}"
                fi
            elif test "[true] 0" != "$(sudo docker inspect --format='{{.Name}} {{.Config.Cmd}} {{.State.ExitCode}}' $(sudo docker ps --all --quiet --no-trunc) | grep "^/${CONTAINER_NAME} " | awk '{print $2, $3}')"; then
                # Don't restart, but run again, see docker issue #3155
#                echo -e "\e[93mRestart container '${CONTAINER_NAME}'\e[0m"
#                sudo docker restart "${CONTAINER_ID}"
                echo -e "\e[93mRerun container '${CONTAINER_NAME}' (docker issue #3155)\e[0m"
                docker rm "${CONTAINER_NAME}"
                source "/env/docker/containers/${CONTAINER_DIRECTORY}/${RUNSCRIPT_FILENAME}"
            else
                echo -e "\e[93mLet data container '${CONTAINER_NAME}'\e[0m"
                echo "${CONTAINER_ID}"
            fi

        done

    fi

fi