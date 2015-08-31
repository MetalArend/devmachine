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

# ====== ====== ====== ====== ====== ======
# Gulp
# ====== ====== ====== ====== ====== ======

# Report
if which gulp &> /dev/null; then
    GULP_VERSION=$(gulp --version | sed 's/^\s*\[[0-9\:]*\]\s*//g' | sed ':a;N;$!ba;s/\n/, /g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g')
    echo -e "\e[92m- gulp ${GULP_VERSION}\e[0m"
else
    echo -e "\e[91m- gulp not found\e[0m"
fi