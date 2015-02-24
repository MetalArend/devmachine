#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# NPM
# ====== ====== ====== ====== ====== ======

# Report
if which npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "\e[92m- npm ${NPM_VERSION}\e[0m"
else
    echo -e "\e[91m- npm not found\e[0m"
fi