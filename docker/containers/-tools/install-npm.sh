#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# NPM
# ====== ====== ====== ====== ====== ======

# Install
if ! which npm &> /dev/null; then
    apt-get update
    curl http://npmjs.org/install.sh | sh
    npm config set registry http://registry.npmjs.org/

#    # Install git, curl, ssl, build essentials
#    sudo apt-get -y install git-core curl build-essential openssl libssl-dev
#
#    # Save current directory
#    CWD=$(pwd)
#
#    # Move to directory to build in
#    cd "/env"
#
#    # Clone npm repository, compile and install
#    git clone git://github.com/isaacs/npm.git
#    cd npm
#    sudo make install
#
#    # Back to old directory
#    cd "${CWD}"

#    # Save current directory
#    CWD=$(pwd)
#
#    # Remove node
#    cd /usr/local
#    sudo rm -rf /usr/local/{lib/node{,/.npm,_modules},bin,share/man}/npm*
#
#    # Back to old directory
#    cd "${CWD}"
fi