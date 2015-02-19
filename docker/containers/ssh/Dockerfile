FROM ubuntu:12.04
MAINTAINER Bart Reunes aka MetalArend

# RUN dpkg-divert --local --rename --add /sbin/initctl
# RUN ln -s /bin/true /sbin/initctl

# RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y openssh-server

RUN mkdir /var/run/sshd
RUN echo "root:root" | chpasswd

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

EXPOSE 22

ENTRYPOINT ["/usr/sbin/sshd"]
CMD ["--help"]