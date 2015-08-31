#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Composer - http://getcomposer.org/doc/00-intro.md#installation-nix
# ====== ====== ====== ====== ====== ======

# Report
if which composer &> /dev/null; then
    COMPOSER_VERSION=$(composer --version | sed 's/^.*version *//g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g')
    echo -e "\e[92m- composer ${COMPOSER_VERSION}\e[0m"
else
    echo -e "\e[91m- composer not found\e[0m"
fi