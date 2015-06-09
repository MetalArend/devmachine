#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Network Time Protocol - http://www.debian-administration.org/article/25/Keeping_your_clock_current_automatically.
# ====== ====== ====== ====== ====== ======

if test ! -f /env/log/time-synced.log; then
    # Set timezone
    sudo rm /etc/localtime
    sudo ln -s /usr/share/zoneinfo/Europe/Brussels /etc/localtime

    # Update time
    sudo ntpdate pool.ntp.org

    # Log time update
    touch /env/log/time-synced.log
    DATETIME=$(date +"%Y/%m/%d %H:%M")
    echo "--- ${DATETIME} ---" >> "/env/log/time-synced.log"
fi

# ====== ====== ====== ====== ====== ======
# Command-Not-Found - http://askubuntu.com/questions/205378/unsupported-locale-setting-fault-by-command-not-found
# ====== ====== ====== ====== ====== ======

if test ! -f /env/log/locales-generated.log; then
    # Set environment
    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # Generate locales
    locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales

    # Log locales generated
    touch /env/log/locales-generated.log
    DATETIME=$(date +"%Y/%m/%d %H:%M")
    echo "--- ${DATETIME} ---" >> "/env/log/locales-generated.log"
fi