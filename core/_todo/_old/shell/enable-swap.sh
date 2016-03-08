#!/bin/bash

echo -e "\e[1;40;33m\nEnable swap\e[0m"
if test -f /swapfile; then
    sudo swapoff /swapfile
fi
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon -s