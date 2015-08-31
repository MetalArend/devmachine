#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Grunt
# ====== ====== ====== ====== ====== ======

# Report
if which grunt &> /dev/null; then
    GRUNT_VERSION=$(grunt --version | sed 's/^grunt *//g')
    echo -e "\e[92m- grunt ${GRUNT_VERSION}\e[0m"
else
    echo -e "\e[91m- grunt not found\e[0m"
fi