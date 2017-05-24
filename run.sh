#!/bin/bash
set -e

echo ""
echo "Checking Postgres Availability..."

until psql -h "db_pg" -U "postgres" -c '\q'; do
  echo "Postgres is unavailable, awaiting for availability"
  sleep 1
done

echo "Postgres is up, executing command"

if ! psql -h "db_pg" -U "postgres" -c '\du' | grep 'pb'; do
  echo "Creating Postgres User..."
  psql -h "db_pg" -U "postgres" -c "CREATE USER pb WITH PASSWORD '123'; ALTER USER your_user CREATEDB;"
fi

redis-server /usr/local/etc/redis.conf

echo "Waiting for app setup to finish..."

cp -fR /home/deploy/src/database.yml /home/deploy/Projects/precios_bajos/config/database.yml
cp -fR /home/deploy/src/application.yml /home/deploy/Projects/precios_bajos/config/application.yml
cp -fR /usr/lib/standalone /home/deploy/

echo "Adding SSH known hosts..."
echo "[stash.tween.com.ar]:7999,[64.76.23.187]:7999 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6IViVf0lURpBgIe4jA4rFWouHfJQjLy01H9u3l/x89D6gF0ad/RcpwBWTWmnQpGbvUkyuybmdjj3G1nt2ylF3WjaibhBIWKMIq7U3riDn+8dxPYvWS3OR6192XV7Ah+4iwHIFUHgQk9yS/VKfH8tO/oSvzjVKImgkXOEgUlXhVf+VxhJhigk2KzyRo+L1lpEZifI3FHEzvmAw83mfUuNxS3LUSMD6GioOaCAuOtHPEynVveXDeNRl7d6Q3NF/IQw6bY/lqZ+6ZUN7xQhM1dCSvn89j55Mme12sgTQH1vK2Tg53Die3e9w/GS9AdTRnT6cgiktVH9IcFbLNVVQ4CQf" > /home/deploy/.ssh/known_hosts
ssh-keyscan -t rsa github.com >> /home/deploy/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> /home/deploy/.ssh/known_hosts

cd /home/deploy/Projects/precios_bajos

echo "Creating Gemset..."
cp .ruby-version.sample .ruby-version
cp .ruby-gemset.sample .ruby-gemset
source ~/.rvm/scripts/rvm
rvm --force gemset delete global
rvm gemset create precios_bajos
rvm gemset use precios_bajos

echo "Installing Bundler..."
gem install bundler --no-rdoc --no-ri -v="1.6.2"
gem install rubygems-bundler --no-rdoc --no-ri -v="1.4.4"
gem install capistrano -v="2.15.4" --no-rdoc --no-ri

echo "Installing Gems..."
bundle check || bundle install --quiet

mkdir -p ./tmp/pids
touch ./tmp/pids/sidekiq.pid

foreman start

echo "Running App..."

/bin/bash
