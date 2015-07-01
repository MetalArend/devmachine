FROM        ubuntu:14.04
MAINTAINER  Bart Reunes "@MetalArend"

# keep services disabled - http://serverfault.com/questions/567474/how-can-i-install-packages-without-starting-their-associated-services
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# add keys
#RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5

# add multiverse
RUN echo "deb http://archive.ubuntu.com/ubuntu precise multiverse" >> /etc/apt/sources.list

# install apache2
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get -yq install \
        apache2 apache2-mpm-worker libapache2-mod-php5 \
        php5 \
        php5-cli php5-mysql php5-gd php5-curl php-pear php-apc php5-mcrypt \
        curl

# Install composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ && \
    mv /usr/bin/composer.phar /usr/bin/composer

# Clean image
RUN apt-get clean && \
    apt-get -f install && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# add directories
RUN mkdir -p /var/run/apache2 /var/lock/apache2

# set environment
ENV APACHE_RUN_USER=www-data \
    APACHE_RUN_GROUP=www-data \
    APACHE_PID_FILE=/var/run/apache2/apache2.pid \
    APACHE_RUN_DIR=/var/run/apache2 \
    APACHE_LOCK_DIR=/var/lock/apache2 \
    APACHE_LOG_DIR=/log \
    APACHE_SERVERADMIN=admin@localhost \
    APACHE_SERVERNAME=localhost \
    APACHE_HOST=* \
    APACHE_PORT=80 \
    APACHE_DOCUMENTROOT="/var/www/html"

# add config files
COPY ./conf/apache2.conf /etc/apache2/sites-enabled/000-default

# enable services
RUN a2enmod rewrite env actions alias

# apache2 should not be running here
#RUN service apache2 restart # preferred instead of "/etc/init.d/apache2 restart"

EXPOSE 80 443

VOLUME ["/log"]

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-help"]
