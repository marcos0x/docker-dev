FROM ubuntu:14.04
MAINTAINER Marcos Avila <marcos.avila@tween.com.ar>

RUN dpkg-divert --local --rename --add /sbin/initctl

RUN apt-get update

RUN apt-get -y install mysql-client mysql-server

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

ADD ./startup.sh /opt/startup.sh

EXPOSE 3306

CMD ["/bin/bash", "/opt/startup.sh"]
