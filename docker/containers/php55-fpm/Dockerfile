FROM ubuntu:12.04
MAINTAINER Bart Reunes aka MetalArend

# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe multiverse" >> /etc/apt/sources.list
RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get install -y python-software-properties
RUN add-apt-repository ppa:ondrej/php5
RUN apt-get update
RUN apt-get install -y php5 php5-fpm php5-xdebug php5-mysql

#RUN touch /log/error.fpm.log
RUN sed -i '/^error_log = /c\error_log = \/log\/\error.log' /etc/php5/fpm/php-fpm.conf # fpm conf
RUN sed -i '/^;access.log = /c\access.log = \/log\/access.log' /etc/php5/fpm/pool.d/www.conf # www conf
RUN sed -i '/^;pm.status_path = /c\pm.status_path = \/status' /etc/php5/fpm/pool.d/www.conf # www conf
RUN sed -i '/^;ping.path = /c\ping.path = \/ping' /etc/php5/fpm/pool.d/www.conf # www conf
RUN sed -i '/^listen /c\listen = 9000' /etc/php5/fpm/pool.d/www.conf # www conf
RUN sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php5/fpm/pool.d/www.conf

RUN sed -i '/daemonize /c\daemonize = no' /etc/php5/fpm/php-fpm.conf # fpm conf

#RUN sed -i 's/;pm.start_servers/pm.start_servers/g' /etc/php5/fpm/pool.d/www.conf

    #??? RUN sed -i "s/;date.timezone =.*/date.timezone = UTC/" /etc/php5/cli/php.ini
    #??? RUN sed -i "s/upload_max_filesize =.*/upload_max_filesize = 250M/" /etc/php5/fpm/php.ini
    #??? RUN sed -i "s/post_max_size =.*/post_max_size = 250M/" /etc/php5/fpm/php.ini

#RUN apt-get --force-yes -y install rinetd
#RUN cp /etc/rinetd.conf /etc/rinetd.conf.backup

RUN apt-get clean && apt-get -f install && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

EXPOSE 9000

ENTRYPOINT ["php5-fpm"]