FROM        ubuntu:14.04
MAINTAINER  Bart Reunes "@MetalArend"

# Installing packages
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install autoconf automake binutils-dev build-essential wget memcached openssl cmake g++ gawk git git-core \
	libboost-dev libboost-filesystem-dev libboost-program-options-dev libboost-regex-dev \
	libboost-system-dev libboost-thread-dev libboost-context-dev libbz2-dev libc-client-dev libldap2-dev \
	libc-client2007e-dev libcap-dev libcurl4-openssl-dev libdwarf-dev libelf-dev \
	libexpat-dev libgd2-xpm-dev libgoogle-glog-dev libgoogle-perftools-dev libicu-dev \
	libjemalloc-dev libmcrypt-dev libmemcached-dev libmysqlclient-dev libncurses-dev \
	libonig-dev libpcre3-dev libreadline-dev libtbb-dev libtool libxml2-dev zlib1g-dev \
	libevent-dev libmagickwand-dev libinotifytools0-dev libiconv-hook-dev libedit-dev \
	libiberty-dev libxslt1-dev ocaml-native-compilers libsqlite3-dev libyaml-dev libgmp3-dev \
	php5 php5-dbg php5-common php5-mysql php5-mcrypt gperf php5-imagick libcloog-ppl0 subversion libgmp10 libmemcachedutil2

# Get HipHop source code
RUN wget -O - http://dl.hhvm.com/conf/hhvm.gpg.key | sudo apt-key add -
RUN echo deb http://dl.hhvm.com/ubuntu trusty main | sudo tee /etc/apt/sources.list.d/hhvm.list
RUN sudo apt-get update
RUN sudo apt-get install -y hhvm

# Configure your webserver to use HHVM:
# RUN sudo /usr/share/hhvm/install_fastcgi.sh
# RUN sudo /etc/init.d/nginx restart
# RUN sudo /etc/init.d/apache restart
# RUN sudo /etc/init.d/hhvm restart

# Run command line scripts with HHVM:
# RUN hhvm whatever.php

# Use HHVM for /usr/bin/php even if you have php-cli installed:
# RUN sudo /usr/bin/update-alternatives --install /usr/bin/php php /usr/bin/hhvm 60

# Removing the pulled repository
WORKDIR /
RUN rm -rf hhvm-repo

# Exposing port
EXPOSE 9000

# Default command
CMD ['hhvm']
# --mode server -vServer.Type=fastcgi -vServer.Port=9000
