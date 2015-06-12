#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Vagrant - http://docs.vagrantup.com/v2/
# ====== ====== ====== ====== ====== ======

# Check current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load configuration
SHELL_SCRIPTS_DIR="${CWD}/shell/scripts"
DOCKER_CONTAINERS_DIRECTORIES="${CWD}/docker/containers/data","${CWD}/docker/containers/mysql56","${CWD}/docker/containers/php54-fpm","${CWD}/docker/containers/lamp54"
IFS=',' read -ra DOCKER_CONTAINERS_DIRECTORIES <<< "${DOCKER_CONTAINERS_DIRECTORIES}"

# Configure system
bash "${SHELL_SCRIPTS_DIR}/devmachine/configure-system.sh" -t "Europe/Brussels"
echo " "

# Install programs
bash "${SHELL_SCRIPTS_DIR}/devmachine/install-composer.sh" -d "${CWD}/composer"
bash "${SHELL_SCRIPTS_DIR}/devmachine/install-gulp.sh"
bash "${SHELL_SCRIPTS_DIR}/docker/install-docker.sh"
echo " "

# Cleanup docker
bash "${SHELL_SCRIPTS_DIR}/docker/cleanup-docker.sh"
echo " "

# Run docker containers
#bash "${SHELL_SCRIPTS_DIR}/docker/run-docker-compose-farm.sh" -d "${CWD}"
for DOCKER_CONTAINER_DIRECTORY in "${DOCKER_CONTAINERS_DIRECTORIES[@]}"; do
    bash "${SHELL_SCRIPTS_DIR}/docker/run-docker-container.sh" -d "${DOCKER_CONTAINER_DIRECTORY}"
done
echo " "

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
#bash "${SHELL_SCRIPTS_DIR}/docker/report-docker-compose-farm.sh" -d "${CWD}"
for DOCKER_CONTAINER_DIRECTORY in "${DOCKER_CONTAINERS_DIRECTORIES[@]}"; do
    bash "${SHELL_SCRIPTS_DIR}/docker/report-docker-container.sh" -d "${DOCKER_CONTAINER_DIRECTORY}"
    echo " "
done

# Run application provision
bash "${SHELL_SCRIPTS_DIR}/devmachine/run-scripts.sh" -d "${CWD}/php" -f "provision.sh"
echo " "
