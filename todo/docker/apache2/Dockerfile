FROM ubuntu:12.04
MAINTAINER Bart Reunes aka MetalArend

# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

RUN echo "deb http://archive.ubuntu.com/ubuntu precise multiverse" >> /etc/apt/sources.list
RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive

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

RUN apt-get install -y apache2 apache2-mpm-worker libapache2-mod-fastcgi
RUN a2enmod rewrite env actions fastcgi alias

RUN apt-get clean && apt-get -f install && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

RUN mkdir -p /var/run/apache2

ADD . /container
RUN cp /container/conf/apache2.conf /etc/apache2/sites-enabled/000-default

#RUN service apache2 restart # preferred instead of "/etc/init.d/apache2 restart" # apache2 didn't even start yet

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-help"]
