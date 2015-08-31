#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Subversion - http://askubuntu.com/questions/55546/how-do-i-install-svn
# ====== ====== ====== ====== ====== ======

# Install
if ! which svn &> /dev/null; then
    apt-get update
    apt-get -y install subversion
fi