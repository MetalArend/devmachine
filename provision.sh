#!/usr/bin/env bash

# Stop after error
set -e

# Use current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CWD}"

# Configure system
bash "${CWD}/shell/configure-system.sh" -t "Europe/Brussels"

# Install
bash "${CWD}/shell/install-docker.sh"

# Cleanup
bash "${CWD}/shell/cleanup-docker.sh"

# Report
bash "${CWD}/shell/report-os.sh"
bash "${CWD}/shell/report-docker.sh"

# Run application provision
find "/env/workspace" -iname "docker-provision.sh" -exec echo -e "\e[93mRun shell script \"{}\"\e[0m" \; -exec bash "{}" \; -exec echo " " \;
