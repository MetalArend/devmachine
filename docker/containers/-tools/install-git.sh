#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Git - http://git-scm.com/book/en/Getting-Started-Installing-Git
# ====== ====== ====== ====== ====== ======

# Install
if ! which git &> /dev/null; then
    apt-get update
    apt-get -y install git-core
fi