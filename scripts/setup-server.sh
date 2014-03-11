#!/bin/bash

REPO=git@github.com:smartlogic/smartchat-api.git
SHA=386668d
DESTDIR=smartchat-api

if [ ! -d "${DESTDIR}" ]; then
  git clone ${REPO} ${DESTDIR}
fi

pushd ${DESTDIR}

# NOTE:`git log --oneline | grep ${SHA}` to figure out if fetch is needed.
git checkout ${SHA}

cat > config/database.yml <<DATABASE_YML
development:
  adapter: postgresql
  database: smartchat_development_ios
  min_messages: warning

DATABASE_YML

# NOTE: `ipconfig getifaddr en0` to get first ethernet IP... not really ideal (wifi)
cat > .env <<DOT_ENV
SMARTCHAT_API_HOST=`hostname`
SMARTCHAT_API_PORT=9090
DOT_ENV

cat > Procfile <<PROCFILE
db: postgres -D `brew --prefix`/var/postgres
redis: redis-server
web: bundle exec rails s thin --port 9090
sidekiq: bundle exec sidekiq -C config/sidekiq.yml
worker: env BUNDLE_GEMFILE=worker/Gemfile bundle exec ./worker/bin/smartchat
PROCFILE

# sidekiq needs thisw
mkdir -p tmp/pids/

# NOTE: Test to see if 2.0 is available
chruby 2.0

bundle
pushd worker
bundle
popd
bundle exec rake db:drop db:create db:setup

foreman start
