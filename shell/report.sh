#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Report
# ====== ====== ====== ====== ====== ======

# Detect OS
OS=$(uname)
ID='unknown'
CODENAME='unknown'
RELEASE='unknown'
ARCH='unknown'

# detect centos
grep 'centos' /etc/issue -i -q
if [ $? = '0' ]; then
    ID='centos'
    RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
elif [ -f '/etc/redhat-release' ]; then
    ID='centos'
    RELEASE=$(cat /etc/redhat-release | grep -o 'release [0-9]' | cut -d " " -f2)
# could be debian or ubuntu
elif [ $(which lsb_release) ]; then
    ID=$(lsb_release -i | cut -f2)
    CODENAME=$(lsb_release -c | cut -f2)
    RELEASE=$(lsb_release -r | cut -f2)
elif [ -f '/etc/lsb-release' ]; then
    ID=$(cat /etc/lsb-release | grep DISTRIB_ID | cut -d "=" -f2)
    CODENAME=$(cat /etc/lsb-release | grep DISTRIB_CODENAME | cut -d "=" -f2)
    RELEASE=$(cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2)
elif [ -f '/etc/issue' ]; then
    ID=$(head -1 /etc/issue | cut -d " " -f1)
    if [ -f '/etc/debian_version' ]; then
      RELEASE=$(</etc/debian_version)
    else
      RELEASE=$(head -1 /etc/issue | cut -d " " -f2)
    fi
fi

ID=$(echo "${ID}" | tr '[A-Z]' '[a-z]')
CODENAME=$(echo "${CODENAME}" | tr '[A-Z]' '[a-z]')
RELEASE=$(echo "${RELEASE}" | tr '[A-Z]' '[a-z]')
ARCH=$(uname -m)

#IP=$(ifconfig eth1 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
IP=$(ip addr show | grep "state UP" -A2 | grep "scope global" | grep -v "docker" | awk '{print $2}' | cut -f1 -d'/' | tr '\n' ' ')

echo -e "\e[92m$(date +"%d/%m/%Y %H:%M:%S")\e[0m"
echo -e "\e[92m${ID} ${RELEASE} (${CODENAME}) on ${IP}\e[0m"

# Detect programs
if which ansible &> /dev/null; then
  echo -e "\e[92m- $(ansible --version | grep 'ansible')\e[0m";
else
  echo -e "\e[91m- ansible not found\e[0m";
fi
if which docker &> /dev/null; then
  echo -e "\e[92m- $(docker --version | sed 's/^Docker version /docker /g') ($(docker info 2>/dev/null | sed -n -e '/Containers:.*/p;/Images:.*/p;/Storage Driver:.*/p' | sed ':a;N;$!ba;s/\n/, /g'))\e[0m";
else
  echo -e "\e[91m- docker not found\e[0m";
fi
if which docker-compose &> /dev/null; then
  echo -e "\e[92m- $(docker-compose --version | sed 's/OpenSSL version: //g' | sed 's/version: //g' | sed ':a;N;$!ba;s/\n/, /g')\e[0m";
else
  echo -e "\e[91m- docker-compose not found\e[0m";
fi