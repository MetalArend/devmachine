#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Grunt
# ====== ====== ====== ====== ====== ======

# Install
if ! which grunt &> /dev/null; then
    sudo npm install -g grunt
fi