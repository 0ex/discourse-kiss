# Discourse KISS

An unofficial container image for [Discourse](https://www.discourse.org/).

This an alternative (simpler and better) way to run discourse.
See the [Related](#Related) section below for a comparison.

## Usage

You don't need this repo to use this image, but it has some example configs
for various methods.

With podman (most tested):

    mkdir -p data/sql
    sudo podman build -t 0ex0/discourse-kiss .
    sudo podman play kube pod.yaml
    sudo podman exec -it discourse-kiss-app bundle exec rake admin:create

With docker-compose:

    docker-compose up
    docker-compose run app bundle exec rake admin:create

With plain docker:

1. Create `discourse.conf` and point to your Redis and PostgreSQL instances.
2. Run:

    docker run --name discourse -p 8013:80 \
        -v $PWD/discourse.conf:/var/www/discourse/conf/ \
        0ex/discourse-kiss
    docker exec -it discourse bundle exec rake admin:create

## Setup

After using one of the methods above you can login:

    open http://localhost:8014/

### Relative URL root

The default config is to serve the forum at http://localhost:8014/forum/. This is configurable
by:

- edit discourse.conf, relative_url_root
- replace all instances of `/forum/` in `nginx.conf` with `/`
- see [Upstream docs](https://meta.discourse.org/t/subfolder-support-with-docker/30507)

## Maintenance

### discourse tools

    bundle exec script/discourse ...

    bundle exec rake --tasks

    bundle exec rake site_settings:export > settings.yml
    bundle exec rake site_settings:import < settings.yml

recompile assets (requires redis and DB):

    export RAILS_ENV=production
    ./bin/bundle exec rake assets:precompile

### podman

    podman run -it --pod discourse-kiss alpine

### redis

    docker-compose run redis redis-cli -h redis
    redis:6379> config set requirepass password123

### postgresql

    docker-compose exec -u 0 postgresql psql -U postgres
    ALTER USER postgres PASSWORD 'password123'

- [entrypoint.sh](https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh).
- initdb: cannot be run as root

## Notes

- [dev install guide](https://github.com/discourse/discourse/blob/master/docs/DEVELOPER-ADVANCED.md)
- https://github.com/discourse/discourse/tree/master/config
    - discourse_defaults.conf
    - site_settings.yml - defaults, but can be set via UI and saved in DB
    - database.yml - does not seem needed
- https://edgeryders.eu/t/discourse-admin-manual/6647

webserver
- Unicorn is a Rack HTTP server to serve Ruby web applications
- open directly: http://localhost:8013/forum

## Related

### Official Launcher

[repo](https://github.com/discourse/discourse_docker)
[image](https://hub.docker.com/r/discourse/base)

Compared to the official method *discourse-light*:

- a smaller image: XXX vs 1GB
- works with plain  `docker run`, kubernetes or any standard OCI runtime.
- it doesn't use a custom "templating" system.

### Bitnami Image

[repo](https://github.com/bitnami/bitnami-docker-discourse)

- I tried this image first (Aug 2020), but wasn't satisfied.
- I wasn't about to get a custom *discorse.conf* working because
  (1) the "installer" would complain if there was only one config file
  in the config directory and (2) migrations didn't work with a custom
  config.
- I sometimes encountered an [ERROR ELOOP](https://github.com/bitnami/bitnami-docker-discourse/issues/134#issuecomment-680717910) bug. The Issue was closed even though it wasn't fixed.
- It uses a custom package system called nami and did way too much
  magic for my liking.
- It took minutes everytime it was started because it recompiled all the static
  assets of discourse.
- I encountered a few other bugs that didn't increase my confidence in this package.
- uses Passenger, an HTTP proxy and process manager.

