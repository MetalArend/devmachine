#!/usr/bin/env bash

# Stop after error
set -e

# Use current directory
CWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "${CWD}"

# ====== ====== ====== ====== ====== ======
# Docker - own implementation, as http://docs.vagrantup.com/v2/provisioning/docker.html is too limited
# ====== ====== ====== ====== ====== ======

# Install docker
if ! which docker &> /dev/null; then
    # Run install script from official docker server
    #curl -sSL https://get.docker.io/ | sh

    # Run install of older docker version
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    #echo "Acquire::HTTP::Proxy::get.docker.com \"DIRECT\";" | sudo tee /etc/apt/apt.conf.d/01proxy
    echo deb https://get.docker.com/ubuntu docker main | sudo tee /etc/apt/sources.list.d/docker.list
    sudo apt-get update; sudo apt-get install -y -q lxc-docker-1.6.0

    if which docker &> /dev/null; then
        # Add the docker group
        sudo groupadd docker
        sudo usermod -aG docker vagrant

        # Add the root and vagrant users to the docker group # TIP: don't use usermod!
        sudo gpasswd -a "${USER}" docker
        sudo gpasswd -a "vagrant" docker

        # Restart docker
        if which service &> /dev/null; then
            if which docker &> /dev/null; then
                sudo service docker restart
            fi
        fi
    fi
#else
#    # Run install script from official docker server
#    curl -sSL https://get.docker.com/ | sh
fi

# Install docker-compose
if ! which docker-compose &> /dev/null; then
    # Run install script from official docker compose github
    curl -sL https://github.com/docker/compose/releases/download/1.3.1/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    # Restart docker
    if which service &> /dev/null; then
        if which docker &> /dev/null; then
            sudo service docker restart
        fi
    fi
fi

if which docker &> /dev/null; then
    echo -e "\e[92m- docker $(docker --version | sed 's/^[^0-9]* //g') ($(docker info 2>/dev/null | sed -n -e '/Containers:.*/,/Images:.*/p' | sed ':a;N;s/\n/, /g'))\e[0m"
else
    echo -e "\e[91m- docker not found\e[0m"
fi

if which docker-compose &> /dev/null; then
    echo -e "\e[92m- $(docker-compose --version | sed 's/version: //g' | sed ':a;N;$!ba;s/\n/, /g')\e[0m"
else
    echo -e "\e[91m- docker-compose not found\e[0m"
fi
