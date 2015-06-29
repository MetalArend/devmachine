FROM ubuntu:12.04
MAINTAINER Bart Reunes aka MetalArend
ENV LAST_UPDATED 2015-04-27

# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" >> /etc/apt/sources.list
RUN apt-get update

# Install packages
ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:ondrej/php5-oldstable
RUN apt-get update && \
    apt-get -y install \
        curl \
        php5 \
        php5-fpm \
        php5-mysqlnd \
        php5-sqlite \
        php5-imagick \
        php5-gd \
        php5-imap \
        php5-mcrypt \
        php5-curl \
        php5-cli \
        php5-common \
        php5-json \
        php5-intl \
        php-pear \
        php5-xdebug

# Clean image
RUN apt-get clean && \
    apt-get -f install && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# Configure php5-fpm
RUN sed -i 's/display_errors = Off/display_errors = On/' /etc/php5/fpm/php.ini && \
    sed -i '/^error_log = /c\error_log = \/log\/\error54.log' /etc/php5/fpm/php-fpm.conf && \
    sed -i '/^;access.log = /c\access.log = \/log\/access54.log' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^;pm.status_path = /c\pm.status_path = \/status' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^;ping.path = /c\ping.path = \/ping' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/^listen /c\listen = 9000' /etc/php5/fpm/pool.d/www.conf && \
    sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php5/fpm/pool.d/www.conf && \
    sed -i '/daemonize /c\daemonize = no' /etc/php5/fpm/php-fpm.conf # fpm conf

#RUN sed -i 's/;pm.start_servers/pm.start_servers/g' /etc/php5/fpm/pool.d/www.conf

    #??? RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
    #??? RUN sed -i "s/upload_max_filesize =.*/upload_max_filesize = 250M/" /etc/php5/fpm/php.ini
    #??? RUN sed -i "s/post_max_size =.*/post_max_size = 250M/" /etc/php5/fpm/php.ini

EXPOSE 9000

ENTRYPOINT ["php5-fpm", "-F"]