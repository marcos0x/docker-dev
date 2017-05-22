FROM ubuntu:14.04
MAINTAINER Marcos Avila <marcos.avila@tween.com.ar>

# Install dependencies
USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    sudo \
    libpq-dev \
    imagemagick \
    nodejs \
    npm \
    git \
    unzip \
    python-software-properties \
    software-properties-common \
    redis-server

# Set locale
RUN locale-gen es_AR.UTF-8
ENV LANG es_AR.UTF-8
ENV LANGUAGE es_AR:es
ENV LC_ALL es_AR.UTF-8

# Install Java
RUN apt-add-repository ppa:webupd8team/java
RUN apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Install ElasticSearch
RUN mkdir -p /usr/lib/standalone
WORKDIR /usr/lib/standalone
RUN wget -qO- -O tmp.zip https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.zip && unzip tmp.zip && rm tmp.zip

# Create User Deploy
RUN useradd --home /home/deploy -M deploy -K UID_MIN=10000 -K GID_MIN=10000 -s /bin/bash
RUN mkdir /home/deploy
RUN chown deploy:deploy /home/deploy
RUN adduser deploy sudo
RUN echo 'deploy ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

VOLUME  ["/home/deploy/.ssh"]

# Install OpenSSH
RUN apt-get install -y openssh-client openssh-server

USER deploy

ENV RUBY_VERSION 2.1.2

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source ~/.rvm/scripts/rvm'

# Install Ruby
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install $RUBY_VERSION'
RUN /bin/bash -l -c 'rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems current'

USER root

VOLUME  ["/var/www/app"]

# Install PostgreSQL
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/postgresql.list

RUN apt-get install -y \
#     postgresql-9.3 \
#     postgresql-contrib-9.3 \
     postgresql-client-9.3

# RUN echo "host all  all 0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf
# RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf

# RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql

# ENV PGDATA /var/lib/postgresql/9.3/main
# RUN chown -R postgres:postgres "$PGDATA"

# USER postgres

# RUN service postgresql start \
#     && psql --command "CREATE USER pb WITH PASSWORD '123';" \
#     && psql --command "ALTER USER pb CREATEDB;"

# VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql/9.3/main"]

# EXPOSE 5432

# USER root

RUN apt-get install -y mysql-client libmysqlclient-dev

EXPOSE 3000

WORKDIR  /var/www/app

COPY run.sh /usr/local/bin
RUN chmod +x /usr/local/bin/run.sh

USER deploy

ENTRYPOINT ["/usr/local/bin/run.sh"]

CMD ["/bin/bash"]
