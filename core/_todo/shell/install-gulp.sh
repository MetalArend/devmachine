#!/usr/bin/env bash

# ====== ====== ====== ====== ====== ======
# Node - https://deb.nodesource.com/
# ====== ====== ====== ====== ====== ======

# http://howtonode.org/how-to-install-nodejs
# https://www.joyent.com/blog/installing-node-and-npm/
# http://ariejan.net/2011/10/24/installing-node-js-and-npm-on-ubuntu-debian/
# http://rodrigothescientist.wordpress.com/2013/04/22/installing-grunt-on-ubuntu-12-04/

# Install
if ! which node &> /dev/null; then
    curl -sL https://deb.nodesource.com/setup | sudo bash -
    sudo apt-get install -y nodejs
fi

## http://blog.nodeknockout.com/post/65463770933/how-to-install-node-js-and-npm
#
## hello_node.js
#var http = require('http');
#http.createServer(function (req, res) {
#  res.writeHead(200, {'Content-Type': 'text/plain'});
#  res.end('Hello Node.js\n');
#}).listen(8124, "127.0.0.1");
#console.log('Server running at http://127.0.0.1:8124/');
#Run the command by typing node hello_node.js in your terminal.
#Now, if you navigate to http://127.0.0.1:8124/ in your browser, you should see the message.

# ====== ====== ====== ====== ====== ======
# npm
# ====== ====== ====== ====== ====== ======

# Install
# Node comes with npm installed so you should have a version of npm.
# However, npm gets updated # more frequently than Node does, so you'll want to make sure it's the latest version.
if ! which npm &> /dev/null; then
    #apt-get update
    #curl http://npmjs.org/install.sh | sh
    #npm config set registry http://registry.npmjs.org/
    npm install --global npm
fi

# ====== ====== ====== ====== ====== ======
# Gulp
# ====== ====== ====== ====== ====== ======

# Install
if ! which gulp &> /dev/null; then
    sudo npm install --global gulp

    # Fix error in plugin 'gulp-notify'
    sudo apt-add-repository ppa:izx/askubuntu
    sudo apt-get update
    sudo apt-get install libnotify-bin
fi


# ====== ====== ====== ====== ====== ======
# Node
# ====== ====== ====== ====== ====== ======

# Report
if which node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo -e "\e[92m- node ${NODE_VERSION}\e[0m"
else
    echo -e "\e[91m- node not found\e[0m"
fi

# ====== ====== ====== ====== ====== ======
# NPM
# ====== ====== ====== ====== ====== ======

# Report
if which npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo -e "\e[92m- npm ${NPM_VERSION}\e[0m"
else
    echo -e "\e[91m- npm not found\e[0m"
fi

# ====== ====== ====== ====== ====== ======
# Gulp
# ====== ====== ====== ====== ====== ======

# Report
if which gulp &> /dev/null; then
    GULP_VERSION=$(gulp --version | sed 's/^\s*\[[0-9\:]*\]\s*//g' | sed ':a;N;$!ba;s/\n/, /g' | sed -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g')
    echo -e "\e[92m- gulp ${GULP_VERSION}\e[0m"
else
    echo -e "\e[91m- gulp not found\e[0m"
fi


