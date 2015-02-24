#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Node - http://howtonode.org/how-to-install-nodejs
# ====== ====== ====== ====== ====== ======

# https://www.joyent.com/blog/installing-node-and-npm/
# http://ariejan.net/2011/10/24/installing-node-js-and-npm-on-ubuntu-debian/
# http://rodrigothescientist.wordpress.com/2013/04/22/installing-grunt-on-ubuntu-12-04/

# Install
if ! which node &> /dev/null; then
    #apt-get update
    #apt-get -y install nodejs nodejs-dev

    apt-get update
    apt-get install -y python-software-properties python g++ make
    add-apt-repository ppa:chris-lea/node.js
    apt-get update
    apt-get install nodejs

#    # Install git, curl, ssl, build essentials
#    sudo apt-get -y install git-core curl build-essential openssl libssl-dev
#
#    # Save current directory
#    CWD=$(pwd)
#
#    # Move to directory to build in
#    cd "/env"
#
#    # Clone Node.js repository, compile and install
#    git clone git://github.com/joyent/node.git
#    cd node
#    git checkout v0.10.28
#    ./configure
#    make
#    sudo make install
#
#    # Back to old directory
#    cd "${CWD}"

#    # Save current directory
#    CWD=$(pwd)
#
#    # Remove node
#    cd /usr/local
#    sudo rm -r bin/node bin/node-waf include/node lib/node lib/pkgconfig/nodejs.pc share/man/man1/node.1
#
#    # Back to old directory
#    cd "${CWD}"
fi