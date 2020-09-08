#!/bin/bash
#
# discourse-kiss entrypoint
#

echo running $0
set -ex

cd /var/www/discourse

mkdir -p /shared/backups
mkdir -p /shared/tmp/{backups,restores}

mkdir -p /shared/log
rm -Rf log
ln -sTf /shared/log log

mkdir -p /shared/assets
ln -sTf /shared/assets public/assets

mkdir -p /shared/uploads/default
ln -sTf /shared/assets public/uploads

mkdir -p /shared/plugin
ln -sTf /shared/plugin plugins/plugin

# for podman - workaround unrecognized hostAliases directive
getent hosts sql || echo "127.0.0.1 sql redis app" >> /etc/hosts

unicorn () {
    export LD_PRELOAD=/usr/lib/libjemalloc.so.1
    bundle exec rake db:migrate
    # bundle exec rake assets:precompile
    bundle exec config/unicorn_launcher -E production -c config/unicorn.conf.rb
}

[ $# = 0 ] && set -- unicorn

"$@"

