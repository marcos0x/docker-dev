FROM ubuntu:14.04
MAINTAINER Marcos Avila <marcos.avila@tween.com.ar>

USER root

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    sudo \
    python-software-properties \
    software-properties-common \
    net-tools \
    telnet \
    openssh-client \
    openssh-server \
    libpq-dev \
    imagemagick \
    nodejs \
    npm \
    git \
    unzip \
    redis-server \
    mysql-client \
    libmysqlclient-dev

# Set locale
RUN locale-gen es_AR.UTF-8
ENV LANG es_AR.UTF-8
ENV LANGUAGE es_AR:es
ENV LC_ALL es_AR.UTF-8

# Create User Deploy
RUN useradd --home /home/deploy -M deploy -K UID_MIN=10000 -K GID_MIN=10000 -s /bin/bash
RUN mkdir /home/deploy
RUN chown deploy:deploy /home/deploy
RUN adduser deploy sudo
RUN echo 'deploy ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install PostgreSQL Client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/postgresql.list
RUN apt-get install -y postgresql-client-9.3

# Install Java
RUN apt-add-repository ppa:webupd8team/java
RUN apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections
RUN apt-get install -y oracle-java8-installer

# Install ElasticSearch
RUN mkdir -p /usr/lib/standalone
WORKDIR /usr/lib/standalone
RUN wget -qO- -O tmp.zip https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.zip && unzip tmp.zip && rm tmp.zip

USER deploy

ENV RUBY_VERSION 2.1.2
ENV RUBYGEMS_VERSION 2.2.2

# Install RVM
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN \curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source ~/.rvm/scripts/rvm'

# Install Ruby
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install $RUBY_VERSION'
RUN /bin/bash -l -c 'rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems $RUBYGEMS_VERSION --force'

USER root

VOLUME  ["/home/deploy/.ssh","/home/deploy/Projects/precios_bajos"]

EXPOSE 3000

RUN echo '127.0.0.1  www.pb.com.ar' >> /etc/hosts
RUN echo '127.0.0.1  public.tiendanevada.com.ar' >> /etc/hosts
RUN echo '127.0.0.1  docker-deploy.pb.com.ar' >> /etc/hosts
RUN echo '130.100.110.33  dsa-webservices' >> /etc/hosts
RUN echo '130.100.69.90  sa-webservices' >> /etc/hosts

COPY elasticsearch.yml /home/deploy/src/elasticsearch.yml
COPY elasticsearch.sh /home/deploy/src/elasticsearch.sh
COPY redis.conf /home/deploy/src/redis.conf
COPY database.yml /home/deploy/src/database.yml
COPY application.yml /home/deploy/src/application.yml
COPY first_store.rake /home/deploy/src/first_store.rake

COPY run.sh /usr/local/bin
RUN chmod +x /usr/local/bin/run.sh

USER deploy

WORKDIR  /home/deploy/Projects/precios_bajos

ENTRYPOINT ["/usr/local/bin/run.sh"]

CMD ["/bin/bash"]
