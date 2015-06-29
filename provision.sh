#!/usr/bin/env bash

# Stop after error
set -e

# Use current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CWD}"

# Configure system
bash "${CWD}/shell/devmachine/configure-system.sh" -t "Europe/Brussels"

# Install
bash "${CWD}/shell/docker/install-docker.sh"

# Print branding & report environment
bash "${CWD}/shell/branding/print-branding.sh"
bash "${CWD}/shell/os/report-os.sh"

# Report docker
bash "${CWD}/shell/docker/report-docker.sh"

# Cleanup
bash "${CWD}/shell/docker/cleanup-docker.sh"

# Run application provision
find "/env/workspace" -iname "docker-provision.sh" -exec echo -e "\e[93mRun shell script \"{}\"\e[0m" \; -exec bash "{}" \; -exec echo " " \;
