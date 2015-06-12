#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Vagrant - http://docs.vagrantup.com/v2/
# ====== ====== ====== ====== ====== ======

# Check current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
SHELL_SCRIPTS_DIR="${CWD}/shell/scripts"
DOCKER_CONTAINERS_DIR="${CWD}/docker/containers"
DOCKER_CONTAINER_FILEPATHS="data","mysql56","php54-fpm","lamp54"
PHP_PROJECTS_DIR="${CWD}/php"

# Configure system
bash "${SHELL_SCRIPTS_DIR}/devmachine/configure-system.sh"

# Install programs
bash "${SHELL_SCRIPTS_DIR}/devmachine/install-composer.sh" -d "/env/composer"
bash "${SHELL_SCRIPTS_DIR}/devmachine/install-gulp.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/install-docker.sh"
echo " "

# Cleanup docker
bash "${SHELL_SCRIPTS_DIR}/docker/cleanup-docker.sh"
echo " "

# Run docker containers
#bash "${SHELL_SCRIPTS_DIR}/docker/run-docker-compose-farm.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/run-docker-containers.sh" "${DOCKER_CONTAINER_FILEPATHS}"

# Print branding, environment and containers
bash "${SHELL_SCRIPTS_DIR}/branding/print-branding.sh"
echo " "

# Print environment
bash "${SHELL_SCRIPTS_DIR}/os/report-os.sh"
echo " "

# Report programs
bash "${SHELL_SCRIPTS_DIR}/devmachine/report-composer.sh"
bash "${SHELL_SCRIPTS_DIR}/devmachine/report-gulp.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/report-docker.sh"
echo " "

# Report docker containers
#bash "${SHELL_SCRIPTS_DIR}/docker/report-docker-compose-farm.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/report-docker-containers.sh" "${DOCKER_CONTAINER_FILEPATHS}"
echo " "

# Run application provision
find "${PHP_PROJECTS_DIR}" -iname "provision.sh" -exec echo -e "\e[93mRunning provisioning file \"{}\"\e[0m" \; -exec bash "{}" \; -exec echo " " \;
echo " "
