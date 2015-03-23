#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Composer - http://getcomposer.org/doc/00-intro.md#installation-nix
# ====== ====== ====== ====== ====== ======

# Variables
COMPOSER_DIRECTORY=""
while getopts "d:" OPTION; do
    case "${OPTION}" in
        d)
            COMPOSER_DIRECTORY="${OPTARG}"
            ;;
        *)
            return
            ;;
    esac
done
if test "" = "${COMPOSER_DIRECTORY}"; then
    return
fi

# Install
if ! which php &> /dev/null; then
    add-apt-repository ppa:ondrej/php5
    apt-get update
    apt-get -y install python-software-properties
    apt-get update
    apt-get -y install php5-fpm php5-cli php5-mcrypt php5-mysql php5-curl
fi

if which php &> /dev/null; then
    if test ! -d "${COMPOSER_DIRECTORY}"; then
        mkdir -p "${COMPOSER_DIRECTORY}"
    fi
    if test ! -f "${COMPOSER_DIRECTORY}/composer.phar"; then
        php -r "readfile('https://getcomposer.org/installer');" | php -- --install-dir="${COMPOSER_DIRECTORY}" | sed -e '/#!\/usr\/bin\/env php/d' -e '/^$/d' -e '/Use it:.*/d'
    else
        "${COMPOSER_DIRECTORY}/composer.phar" self-update | sed -e '/You are already using.*/d'
    fi
    if test ! -f "${COMPOSER_DIRECTORY}/composer.phar"; then
        echo -e "\e[91mComposer not installed.\e[0m"
    else
        sudo ln -s -f "${COMPOSER_DIRECTORY}/composer.phar" "/usr/bin/composer"
        if test ! -h "/usr/bin/composer"; then
            echo -e "\e[91mComposer could not be symlinked to /usr/bin/composer.\e[0m"
        fi
    fi
fi
