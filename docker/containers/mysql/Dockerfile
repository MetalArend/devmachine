FROM ubuntu:12.04
MAINTAINER Bart Reunes aka MetalArend

# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

# RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

# Avoid interaction # check debconf-get-selections | grep mysql-server
RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections

# Ignore the post install questions
ENV DEBIAN_FRONTEND noninteractive

# Install
RUN apt-get -y install mysql-server

# Secure the installation
#RUN mysql_secure_installation # Commented out, as it is not needed for your local environment

ADD . /container
RUN cp /container/conf/mysql.cnf /etc/mysql/conf.d/mysql.cnf
RUN cp /container/conf/mysql.sql /etc/mysql/conf.d/mysql.sql

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

EXPOSE 3306

ENTRYPOINT ["/usr/bin/mysqld_safe"]
CMD ["--help"]