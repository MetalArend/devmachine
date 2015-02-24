#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Curl - http://blog.innodh.com/enable-and-install-curl-in-apache-ubuntu/
# ====== ====== ====== ====== ====== ======

# Report
if which curl &> /dev/null; then
    CURL_VERSION=$(curl --version | sed -n -e 's/^[^0-9]* //g;s/ libcurl.*//p')
    echo -e "\e[92m- curl ${CURL_VERSION}\e[0m"
else
    echo -e "\e[91m- curl not found\e[0m"
fi