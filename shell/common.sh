#!/usr/bin/env bash

check_container () {
    local CONTAINER_NAME CONTAINER_PORT MAX_FAILS=10 TIME_BEGIN=$(date +%s)

    while [[ ${1} ]]; do
        local PARAMETER="${1:2}"

        case "${PARAMETER}" in
            container)
                CONTAINER_NAME=${2}
                shift
                ;;
            port)
                CONTAINER_PORT=${2}
                shift
                ;;
            timeout)
                MAX_FAILS=${2}
                shift
                ;;
            *)
                echo "Unknown parameter \"${PARAMETER}\"" >&2
                return 1
        esac

        if ! shift; then
            echo 'Missing argument' >&2
            return 1
        fi
    done

    echo -ne "Checking container \"${CONTAINER_NAME}\" \033[0K\r" >&2
    local CONTAINER_ID="$(docker-compose ps -q "${CONTAINER_NAME}")"
    if test -z "${CONTAINER_ID}"; then
        echo -e "\033[2K\r\e[31mContainer \"${CONTAINER_NAME}\" not found\e[0m" >&2
        return 1
    else
        local CONTAINER_IP="$(docker inspect --format="{{.NetworkSettings.IPAddress}}" "${CONTAINER_ID}")"
        local CONTAINER_READY=false
        if test -z "${CONTAINER_IP}" || ! ping -c 1 ${CONTAINER_IP} >/dev/null 2>&1; then
            echo -e "\033[2K\r\e[31mContainer \"${CONTAINER_NAME}\" not running\e[0m" >&2
            return 1
        else
            local FAILS=0
            while true; do
                if ! nc -z -w1 ${CONTAINER_IP} ${CONTAINER_PORT}; then
                    FAILS=$[FAILS + 1]
                    if test ${FAILS} -gt ${MAX_FAILS}; then
                        echo -e "\033[2K\rContainer \"${CONTAINER_NAME}\" not responding (timeout)" >&2
                        return 1
                    fi
                    local TIME_PASSED="$[$(date +%s) - $TIME_BEGIN]"
                    echo -ne "\033[2K\rWaiting for container \"${CONTAINER_NAME}\" - ${TIME_PASSED} seconds \033[0K\r" >&2
                    sleep 1
                    continue
                fi
                echo -e "\033[2KContainer \"${CONTAINER_NAME}\" ready" >&2
                return 0
            done
        fi
    fi
    return 1
}