FROM ubuntu:18.04
LABEL maintainer="Marcos Avila <marcos0x@gmail.com>"

RUN dpkg-divert --local --rename --add /sbin/initctl

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    mysql-client \
    mysql-server

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf

ADD ./startup.sh /opt/startup.sh

EXPOSE 3306

CMD ["/bin/bash", "/opt/startup.sh"]
