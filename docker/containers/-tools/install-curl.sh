#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Curl - http://blog.innodh.com/enable-and-install-curl-in-apache-ubuntu/
# ====== ====== ====== ====== ====== ======

# Install
if ! which curl &> /dev/null; then
    apt-get update
    apt-get -y install curl
fi