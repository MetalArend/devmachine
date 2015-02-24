#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Node
# ====== ====== ====== ====== ====== ======

# Report
if which node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "\e[92m- node ${NODE_VERSION}\e[0m"
else
    echo -e "\e[91m- node not found\e[0m"
fi