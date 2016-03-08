#!/usr/bin/env bash

# Install curl - http://blog.innodh.com/enable-and-install-curl-in-apache-ubuntu/
if ! which curl &> /dev/null; then
    apt-get update
    apt-get -y install curl
fi
if which curl &> /dev/null; then
    CURL_VERSION=$(curl --version | sed -n -e 's/^[^0-9]* //g;s/ libcurl.*//p')
    echo -e "\e[92m- curl ${CURL_VERSION}\e[0m"
else
    echo -e "\e[91m- curl not found\e[0m"
fi

# Install git - http://git-scm.com/book/en/Getting-Started-Installing-Git
if ! which git &> /dev/null; then
    apt-get update
    apt-get -y install git-core
fi
if which git &> /dev/null; then
    GIT_VERSION=$(git --version | sed 's/^[^0-9]* //g' )
    echo -e "\e[92m- git ${GIT_VERSION}\e[0m"
else
    echo -e "\e[91m- git not found\e[0m"
fi

# Install grunt
if ! which grunt &> /dev/null; then
    sudo npm install -g grunt
fi
if which grunt &> /dev/null; then
    GRUNT_VERSION=$(grunt --version | sed 's/^grunt *//g')
    echo -e "\e[92m- grunt ${GRUNT_VERSION}\e[0m"
else
    echo -e "\e[91m- grunt not found\e[0m"
fi

# Install subversion - http://askubuntu.com/questions/55546/how-do-i-install-svn
if ! which svn &> /dev/null; then
    apt-get update
    apt-get -y install subversion
fi
if which svn &> /dev/null; then
    SVN_VERSION=$(svn --version --quiet 2>/dev/null)
    echo -e "\e[92m- svn ${SVN_VERSION}\e[0m"
else
    echo -e "\e[91m- svn not found\e[0m"
fi

# Install composer - http://getcomposer.org/doc/00-intro.md#installation-nix
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

if which composer &> /dev/null; then
    COMPOSER_VERSION=$(composer --version | sed 's/^.*version *//g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g')
    echo -e "\e[92m- composer ${COMPOSER_VERSION}\e[0m"
else
    echo -e "\e[91m- composer not found\e[0m"
fi
