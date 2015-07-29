#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Command-Not-Found - http://askubuntu.com/questions/205378/unsupported-locale-setting-fault-by-command-not-found
# ====== ====== ====== ====== ====== ======

if test ! -f ".locales-generated"; then
    # Set environment
    export LANGUAGE=en_US.UTF-8
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8

    # Generate locales
    echo -e "\e[93mGenerate locales for UTF-8\e[0m"
    locale-gen en_US.UTF-8
    sudo dpkg-reconfigure locales

    # Log locales generated
    touch ".locales-generated"
    DATETIME=$(date +"%Y/%m/%d %H:%M")
    echo "--- ${DATETIME} ---" >> ".locales-generated"
fi

# ====== ====== ====== ====== ====== ======
# Network Time Protocol - http://www.debian-administration.org/article/25/Keeping_your_clock_current_automatically.
# ====== ====== ====== ====== ====== ======

# Variables
TIMEZONE=""
while getopts "t:" OPTION; do
    case "${OPTION}" in
        t)
            TIMEZONE="${OPTARG}"
            ;;
        *)
            return
            ;;
    esac
done
if test "" = "${TIMEZONE}"; then
    return
fi

# Set timezone
if test ! -f "/usr/share/zoneinfo/${TIMEZONE}"; then
    echo "Timezone \"${TIMEZONE}\" not found!" # TODO add red coloring
else
    sudo rm /etc/localtime
    sudo ln -s "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
fi

# Update time
echo -e "\e[93mUpdate time for ${TIMEZONE}\e[0m"
sudo ntpdate pool.ntp.org