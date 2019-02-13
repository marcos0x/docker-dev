FROM ubuntu:18.04

LABEL maintainer="Marcos Avila <marcos0x@gmail.com>"

USER root

# Replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Set debconf to run non-interactively
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    sudo \
    locales \
    software-properties-common \
    gnupg2 \
    gpg-agent \
    dirmngr \
    python-minimal \
    net-tools \
    telnet \
    openssh-client \
    openssh-server \
    libpq-dev \
    imagemagick \
    git \
    unzip \
    nginx \
    redis-server \
    mysql-client \
    libmysqlclient-dev \
    zsh

# Set locale
RUN locale-gen es_AR.UTF-8
ENV LANG es_AR.UTF-8
ENV LANGUAGE es_AR:es
ENV LC_ALL es_AR.UTF-8

# Create User develop
RUN useradd --home /home/develop -M develop -K UID_MIN=10000 -K GID_MIN=10000 -s /bin/bash \
    && mkdir /home/develop \
    && chown develop:develop /home/develop \
    && adduser develop sudo \
    && echo 'develop ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Install PostgreSQL Client
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main" > /etc/apt/sources.list.d/postgresql.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update && apt-get install -y -q --no-install-recommends postgresql-common postgresql-client-9.3

# Install Java
RUN apt-add-repository ppa:webupd8team/java \
    && apt-get update \
    && echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections \
    && apt-get install -y oracle-java8-installer

# Install ElasticSearch
RUN mkdir -p /usr/lib/standalone
WORKDIR /usr/lib/standalone
RUN wget -qO- -O tmp.zip https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.5.2.zip \
    && unzip tmp.zip \
    && rm tmp.zip

USER develop
WORKDIR /home/develop
ENV HOME="/home/develop"

# Install Antigen
RUN curl -L git.io/antigen > antigen.zsh

# Install Oh My ZSH
RUN wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# Install NVM
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
ENV NVM_DIR="$HOME/.nvm"
ENV NODE_VERSION 8.13.0
RUN chmod u+x /home/develop/.nvm/nvm.sh \
    && . $NVM_DIR/nvm.sh \
    && chmod u+x /home/develop/.nvm/bash_completion \
    && . $NVM_DIR/bash_completion \
    && nvm install $NODE_VERSION \
    && nvm alias default $NODE_VERSION \
    && nvm use default
ENV NODE_PATH $NVM_DIR/versions/node/v$NODE_VERSION/lib/node_modules
ENV PATH $NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH

# Install Yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
ENV PATH $HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH

# Install Node Global Packages
RUN yarn global add babel-cli \
    clang-format \
    create-react-app \
    eslint \
    express-generator \
    firebase-tools \
    generator-code \
    gulp \
    gulp-cli \
    jasmine \
    jest \
    list-scripts \
    npm \
    pure-prompt \
    react-devtools \
    react-native-cli \
    react-native-git-upgrade \
    serverless \
    speed-test \
    to \
    tslint \
    typescript \
    typings \
    update \
    yarn-completions \
    yo

ENV RUBY_VERSION 2.1.2
ENV RUBYGEMS_VERSION 2.2.2

# Install RVM
RUN echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf
# RUN gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
RUN curl -sSL https://get.rvm.io | bash -s stable
RUN /bin/bash -l -c 'source ~/.rvm/scripts/rvm'

# Install Ruby
RUN /bin/bash -l -c 'rvm requirements'
RUN /bin/bash -l -c 'rvm install $RUBY_VERSION'
RUN /bin/bash -l -c 'rvm use $RUBY_VERSION --default'
RUN /bin/bash -l -c 'rvm rubygems $RUBYGEMS_VERSION --force'

USER root

VOLUME  ["/home/develop/.ssh","/home/develop/Projects"]

EXPOSE 3000

RUN echo '127.0.0.1  localhost' >> /etc/hosts

COPY home/.bash_history /home/develop/.bash_history
COPY home/.bashrc /home/develop/.bashrc
COPY home/.gitconfig /home/develop/.gitconfig
COPY home/.zsh_history /home/develop/.zsh_history
COPY home/.zshrc /home/develop/.zshrc

COPY redis.conf /home/develop/redis.conf
COPY database.yml /home/develop/database.yml
COPY docker.yml /home/develop/docker.yml

COPY run.sh /usr/local/bin
RUN chmod +x /usr/local/bin/run.sh

USER develop

WORKDIR  /home/develop/Projects

ENTRYPOINT ["/usr/local/bin/run.sh"]

CMD ["echo 'Starting Development Environment...'"]
