#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Git - http://git-scm.com/book/en/Getting-Started-Installing-Git
# ====== ====== ====== ====== ====== ======

# Report
if which git &> /dev/null; then
    GIT_VERSION=$(git --version | sed 's/^[^0-9]* //g' )
    echo -e "\e[92m- git ${GIT_VERSION}\e[0m"
else
    echo -e "\e[91m- git not found\e[0m"
fi