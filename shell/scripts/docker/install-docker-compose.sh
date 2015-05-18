#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker-compose
# ====== ====== ====== ====== ====== ======

# Install
if ! which docker-compose &> /dev/null; then
    # Run install script from official docker compose github
    curl -L https://github.com/docker/compose/releases/download/1.2.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi

# Restart the daemon
if which service &> /dev/null; then
    sudo service docker restart
fi
