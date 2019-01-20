#!/bin/bash
set -ex

HOME=/home/deploy
PROJECT=$HOME/Projects/precios_bajos

cd $PROJECT
chmod -R 777 $PROJECT/tmp

echo "Checking Postgres Availability..."

until psql -h db_pg -U postgres -c '\q'; do
  echo "Postgres is unavailable, awaiting for availability"
  sleep 1
done

echo "Postgres is up, executing command"

echo "Starting Redis Server..."

sudo cp -f $HOME/src/redis.conf /usr/local/etc/redis.conf
redis-server /usr/local/etc/redis.conf --daemonize yes

echo "Waiting for app setup to finish..."

cp -fR /usr/lib/standalone $PROJECT
cp -f $HOME/src/elasticsearch.yml $PROJECT/standalone/elasticsearch-1.5.2/config/elasticsearch.yml
cp -f $HOME/src/elasticsearch.sh $PROJECT/standalone/elasticsearch-1.5.2/elasticsearch.sh
cp -f $HOME/src/database.yml $PROJECT/config/database.yml
cp -f $HOME/src/docker.yml $PROJECT/config/docker.yml
cp -f $HOME/src/first_store.rake $PROJECT/lib/tasks/first_store.rake

echo "Adding SSH known hosts..."
echo "[stash.tween.com.ar]:7999,[64.76.23.187]:7999 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6IViVf0lURpBgIe4jA4rFWouHfJQjLy01H9u3l/x89D6gF0ad/RcpwBWTWmnQpGbvUkyuybmdjj3G1nt2ylF3WjaibhBIWKMIq7U3riDn+8dxPYvWS3OR6192XV7Ah+4iwHIFUHgQk9yS/VKfH8tO/oSvzjVKImgkXOEgUlXhVf+VxhJhigk2KzyRo+L1lpEZifI3FHEzvmAw83mfUuNxS3LUSMD6GioOaCAuOtHPEynVveXDeNRl7d6Q3NF/IQw6bY/lqZ+6ZUN7xQhM1dCSvn89j55Mme12sgTQH1vK2Tg53Die3e9w/GS9AdTRnT6cgiktVH9IcFbLNVVQ4CQf" > $HOME/.ssh/known_hosts
ssh-keyscan -t rsa github.com >> $HOME/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> $HOME/.ssh/known_hosts

mkdir -p $PROJECT/tmp/pids
mkdir -p /tmp/pids
touch /tmp/pids/sidekiq.pid
touch $PROJECT/tmp/pids/sidekiq.pid

if [ ! -d "$PROJECT/standalone/elasticsearch-1.5.2/plugins/marvel" ]; then
  $PROJECT/standalone/elasticsearch-1.5.2/bin/plugin -i elasticsearch/marvel/latest
fi

chmod +x $PROJECT/standalone/elasticsearch-1.5.2/elasticsearch.sh
sudo bash $PROJECT/standalone/elasticsearch-1.5.2/elasticsearch.sh start

echo "Creating Gemset..."
cp .ruby-version.sample .ruby-version
cp .ruby-gemset.sample .ruby-gemset
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> $HOME/.bashrc
echo "gem: --no-rdoc --no-ri" > $HOME/.gemrc
rvm --force gemset delete global
rvm gemset use precios_bajos

echo "Installing Gems..."
gem install bundler --no-rdoc --no-ri -v="1.6.2"
gem install rubygems-bundler --no-rdoc --no-ri -v="1.4.4"
gem install capistrano -v="2.15.4" --no-rdoc --no-ri

#bundle check
bundle install --quiet

if ! psql -h db_pg -U postgres -c '\du' | cut -d \| -f 1 | grep -qw 'pb'; then
  echo "Creating Postgres User..."
  psql -h db_pg -U postgres -c "CREATE USER pb WITH PASSWORD '123';"
  psql -h db_pg -U postgres -c "ALTER USER db CREATEDB;"
fi

if ! psql -h db_pg -U postgres -lqt | cut -d \| -f 1 | grep -qw "precios_bajos_development"; then
  echo "Creating Database..."
  bundle exec rake db:create

  echo "Creating Tables..."
  bundle exec rake db:schema:load
fi

if ! psql -h db_pg -U postgres -t -d precios_bajos_development -c "SELECT * FROM spree_taxonomies LIMIT 1;" | cut -d \| -f 2 | grep -qw "Música"; then
  echo "Inserting Data..."
  bundle exec rake db:seed:ar
  bundle exec rake spree_elasticsearch:load_all_models
  bundle exec rake spree_elasticsearch:update_products
fi

bundle exec rake first_store:create

sudo bash $PROJECT/standalone/elasticsearch-1.5.2/elasticsearch.sh stop

echo "Starting Server..."

foreman start

echo "Running App..."

bash
