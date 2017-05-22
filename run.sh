#!/bin/bash
set -e

# if [ ! -d /usr/local/logs ]; then
#   mkdir -p /usr/local/logs
# fi
# cd /usr/local/logs

# LOG_FILE=docker.log
# if [ ! -f $LOG_FILE ]; then
#   touch $LOG_FILE
# fi

# exec 3>&1 1>>${LOG_FILE} 2>&1

echo "Checking Postgres Availability..."

# sudo -u postgres -H sh -c "/usr/lib/postgresql/9.3/bin/postgres -D /var/lib/postgresql/9.3/main -c config_file=/etc/postgresql/9.3/main/postgresql.conf"

#cmd="$@"

until psql -h "db_pg" -U "postgres" -c '\q'; do
  echo "Postgres is unavailable - sleeping"
  sleep 1
done

echo "Postgres is up - executing command"

echo "Waiting for app setup to finish..."

#cp -fR /usr/lib/standalone /var/www/app/

echo "Add SSH known hosts"
echo "[stash.tween.com.ar]:7999,[64.76.23.187]:7999 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC6IViVf0lURpBgIe4jA4rFWouHfJQjLy01H9u3l/x89D6gF0ad/RcpwBWTWmnQpGbvUkyuybmdjj3G1nt2ylF3WjaibhBIWKMIq7U3riDn+8dxPYvWS3OR6192XV7Ah+4iwHIFUHgQk9yS/VKfH8tO/oSvzjVKImgkXOEgUlXhVf+VxhJhigk2KzyRo+L1lpEZifI3FHEzvmAw83mfUuNxS3LUSMD6GioOaCAuOtHPEynVveXDeNRl7d6Q3NF/IQw6bY/lqZ+6ZUN7xQhM1dCSvn89j55Mme12sgTQH1vK2Tg53Die3e9w/GS9AdTRnT6cgiktVH9IcFbLNVVQ4CQf" > /home/deploy/.ssh/known_hosts
ssh-keyscan -t rsa bitbucket.org >> /home/deploy/.ssh/known_hosts
ssh-keyscan -t rsa github.com >> /home/deploy/.ssh/known_hosts

cd /var/www/app

echo "Create Gemset"
cp .ruby-version.sample .ruby-version
cp .ruby-gemset.sample .ruby-gemset
source ~/.rvm/scripts/rvm
# rvm --force gemset delete global
rvm gemset create precios_bajos
rvm gemset use precios_bajos

echo "Install Bundler"
gem install bundler --no-rdoc --no-ri -v="1.6.2"

#bundle check

# gem install spree -v '2.3.13'
# gem install spree_frontend -v '2.3.13'
# gem install spree_backend -v '2.3.13'
# gem install shopping_mall -v '0.0.4'

#bundle install --quiet

# bundle exec rails s -p 3000 -b '0.0.0.0'

echo "Running App..."

/bin/bash
