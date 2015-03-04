#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Command-Not-Found - http://askubuntu.com/questions/205378/unsupported-locale-setting-fault-by-command-not-found
# ====== ====== ====== ====== ====== ======

# Update locales
if test ! -f /tmp/locales-generated; then
    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
    locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales
    touch /tmp/locales-generated
fi