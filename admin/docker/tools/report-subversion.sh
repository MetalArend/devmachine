#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Subversion - http://askubuntu.com/questions/55546/how-do-i-install-svn
# ====== ====== ====== ====== ====== ======

# Report
if which svn &> /dev/null; then
    SVN_VERSION=$(svn --version --quiet 2>/dev/null)
    echo -e "\e[92m- svn ${SVN_VERSION}\e[0m"
else
    echo -e "\e[91m- svn not found\e[0m"
fi