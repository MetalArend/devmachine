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

# TODO test node.js
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

