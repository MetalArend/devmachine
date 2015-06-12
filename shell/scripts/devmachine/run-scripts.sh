#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Provision scripts
# ====== ====== ====== ====== ====== ======

# Variables
PROVISION_DIR=""
PROVISION_FILENAME=""
while getopts "d:f:" OPTION; do
    case "${OPTION}" in
        d)
            PROVISION_DIR="${OPTARG}"
            ;;
        f)
            PROVISION_FILENAME="${OPTARG}"
            ;;
        *)
            return
            ;;
    esac
done
if test "" = "${PROVISION_DIR}" || test "" = "${PROVISION_FILENAME}"; then
    return
fi

find "${PROVISION_DIR}" -iname "${PROVISION_FILENAME}" -exec echo -e "\e[93mRun shell script \"{}\"\e[0m" \; -exec bash "{}" \; -exec echo " " \;