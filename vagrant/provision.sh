#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Vagrant - http://docs.vagrantup.com/v2/
# ====== ====== ====== ====== ====== ======

# Check current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Set timezone
# TODO sudo cp /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# fix command crashed
# TODO http://ivaniliev.com/sorry-command-not-found-has-crashed/

# Variables
source "${CWD}/config/config.sh"

# Run docker
bash "${CWD}/shell/scripts/docker/install-docker.sh"
bash "${CWD}/shell/scripts/docker/run-docker-containers.sh" "${DOCKER_CONTAINER_FILEPATHS}"

# Print branding, environment and containers
bash "${CWD}/shell/scripts/branding/print-branding.sh"
bash "${CWD}/shell/scripts/os/report-os.sh"
bash "${CWD}/shell/scripts/docker/report-docker.sh"
bash "${CWD}/shell/scripts/docker/report-docker-containers.sh" "${DOCKER_CONTAINER_FILEPATHS}"