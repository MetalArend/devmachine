#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Vagrant - http://docs.vagrantup.com/v2/
# ====== ====== ====== ====== ====== ======

# Check current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
CONFIG_DIR="${CWD}/config"
SHELL_SCRIPTS_DIR="${CWD}/shell/scripts"
DOCKER_CONTAINERS_DIR="${CWD}/docker/containers"
PHP_PROJECTS_DIR="${CWD}/php"

# Set timezone
# TODO cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# fix command crashed
# TODO http://ivaniliev.com/sorry-command-not-found-has-crashed/

# Variables
source "${CONFIG_DIR}/config.sh"

# Run docker
bash "${SHELL_SCRIPTS_DIR}/devmachine/install-composer.sh" -d "/env/composer"
bash "${SHELL_SCRIPTS_DIR}/docker/install-docker.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/run-docker-containers.sh" "${DOCKER_CONTAINER_FILEPATHS}"

# Run application provision
# TODO check the php dir for provision.sh files
find "${PHP_PROJECTS_DIR}" -name "provision.sh" -exec bash "{}" \;

# Print branding, environment and containers
bash "${SHELL_SCRIPTS_DIR}/branding/print-branding.sh"
bash "${SHELL_SCRIPTS_DIR}/os/report-os.sh"
bash "${SHELL_SCRIPTS_DIR}/devmachine/report-composer.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/report-docker.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/report-docker-containers.sh" "${DOCKER_CONTAINER_FILEPATHS}"