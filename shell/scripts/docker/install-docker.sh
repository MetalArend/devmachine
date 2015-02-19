#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Docker - own implementation, as http://docs.vagrantup.com/v2/provisioning/docker.html is too limited
# ====== ====== ====== ====== ====== ======

# Install
if ! which docker &> /dev/null; then
    # Run install script from official docker server
    curl -sL https://get.docker.io/ | sh

    # Add the docker group
    sudo groupadd docker

    # Add the root and vagrant users to the docker group # TIP: don't use usermod!
    sudo gpasswd docker -a "${USER}"
    sudo gpasswd docker -a "vagrant"
fi

# Restart the daemon
if which service &> /dev/null; then
    sudo service docker restart
fi
