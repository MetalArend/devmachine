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
        apache2 \
        apache2-mpm-worker \
        libapache2-mod-php5 curl php5-mysql php5-gd php5-curl php-pear php-apc

# Install composer globally
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ && \
    mv /usr/bin/composer.phar /usr/bin/composer

# Clean image
RUN apt-get clean && \
    apt-get -f install && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# add directories
RUN mkdir -p /var/run/apache2
RUN mkdir -p /var/lock/apache2

# enable services
RUN a2enmod rewrite env actions alias

# COPY ./conf/apache2.conf /etc/apache2/sites-available/001-docker.conf
# RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/
COPY ./conf/apache2.conf /etc/apache2/sites-enabled/000-default
# COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
#COPY ./conf/httpd.conf /etc/apache2/conf.d/php5-fpm.conf
#COPY ./conf/httpd.conf /etc/apache2/conf-available/001-docker.conf
#RUN ln -s /etc/apache2/conf-available/001-docker.conf /etc/apache2/conf-enabled/

# set environment
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_PID_FILE /var/run/apache2.pid
ENV APACHE_RUN_DIR /var/run/apache2
ENV APACHE_LOCK_DIR /var/lock/apache2

ENV APACHE_LOG_DIR /log
ENV APACHE_SERVERADMIN admin@localhost
ENV APACHE_SERVERNAME localhost
ENV APACHE_HOST *
ENV APACHE_PORT 80
ENV APACHE_DOCUMENTROOT /var/www

# apache2 should not be running here
#RUN service apache2 restart # preferred instead of "/etc/init.d/apache2 restart"

EXPOSE 80 443

VOLUME ["/log"]

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-help"]
