FROM        ubuntu:12.04
MAINTAINER  Bart Reunes "@MetalArend"

# keep services disabled - http://serverfault.com/questions/567474/how-can-i-install-packages-without-starting-their-associated-services
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# add keys
#RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 40976EAF437D05B5

# add multiverse
RUN echo "deb http://archive.ubuntu.com/ubuntu precise multiverse" >> /etc/apt/sources.list

# install apache2
RUN DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install -y apache2 apache2-mpm-worker libapache2-mod-fastcgi

# cleanup
RUN apt-get clean && apt-get -f install && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# add directories
RUN mkdir -p /var/run/apache2

# enable services
RUN a2enmod rewrite env actions fastcgi alias

#COPY ./conf/apache2.conf /etc/apache2/sites-available/001-docker.conf
#RUN ln -s /etc/apache2/sites-available/001-docker.conf /etc/apache2/sites-enabled/
COPY ./conf/apache2.conf /etc/apache2/sites-enabled/000-default
#COPY ./conf/httpd.conf /usr/local/apache2/conf/httpd.conf
#COPY ./conf/httpd.conf /etc/apache2/conf.d/php5-fpm.conf
#COPY ./conf/httpd.conf /etc/apache2/conf-available/001-docker.conf
#RUN ln -s /etc/apache2/conf-available/001-docker.conf /etc/apache2/conf-enabled/

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

#RUN service apache2 restart # preferred instead of "/etc/init.d/apache2 restart" # apache2 didn't even start yet

EXPOSE 80

ENTRYPOINT ["/usr/sbin/apache2"]
CMD ["-help"]
