# Discourse KISS

[
![AGPL](https://img.shields.io/badge/license-AGPL-blue.svg)
](http://www.gnu.org/licenses/agpl-3.0)
[
![issues](https://img.shields.io/github/issues-raw/0ex/discourse-kiss?label=issues)
](https://github.com/0ex/discourse-kiss/issues) 
[
![commit](https://img.shields.io/github/last-commit/0ex/discourse-kiss.svg?label=commit)
![stars](https://img.shields.io/github/stars/0ex/discourse-kiss.svg)
![tag](https://img.shields.io/github/v/tag/0ex/discourse-kiss)
](https://github.com/0ex/discourse-kiss)
[
![build](https://img.shields.io/docker/cloud/build/0ex0/discourse-kiss?label=build)
![pulls](https://img.shields.io/docker/pulls/0ex0/discourse-kiss?label=pulls)
](https://hub.docker.com/r/0ex0/discourse-kiss)

An unofficial container image for [Discourse](https://www.discourse.org/).

This an alternative (simpler and better) way to run discourse.
See the [Related](#Related) section below for a comparison.

## Getting Started

Choose one of the 3 supported methods.

### Manually

This image can be used anywhere OCI containers can be used.

1. Prepare dependencies: an OCI container runtime, PostgreSQL, Redis
1. Optional: Nginx
1. Create a `discourse.conf` with your hostname, redis and db details.
1. Start the container.
- You should map /shared to a persistent volume.
- Map port 3000 to host port 80 or point your nginx instance to it.
1. In the container, run:

```
bundle exec rake assets:precompile
bundle exec rake admin:create
```

1. Open the mapped port in your browser.

### With Podman

    mkdir -p data/sql
    sudo podman play kube pod.yaml
    sudo podman exec -it discourse-kiss-app bundle exec rake assets:precompile
    sudo podman exec -it discourse-kiss-app bundle exec rake admin:create
    open http://localhost:8014/
    
to update the image:

    sudo podman build -t docker.io/0ex0/discourse-kiss .

### With docker-compose

    docker-compose up
    docker-compose run app bundle exec rake assets:precompile
    docker-compose run app bundle exec rake admin:create
    open http://localhost:8014/

## Maintenance

### Using a relative URL root

The default config is to serve the forum at http://localhost:8014/forum/. This is configurable
by:

- edit discourse.conf, relative_url_root
- replace all instances of `/forum/` in `nginx.conf` with `/`
- see [Upstream docs](https://meta.discourse.org/t/subfolder-support-with-docker/30507)

### admin tasks

misc:

    bundle exec script/discourse ...
    bundle exec rake --tasks

settings:

    bundle exec rake site_settings:export > settings.yml
    bundle exec rake site_settings:import < settings.yml

upstream docs:

- [dev install guide](https://github.com/discourse/discourse/blob/master/docs/DEVELOPER-ADVANCED.md)

### discourse config

- https://github.com/discourse/discourse/tree/master/config
    - discourse_defaults.conf
    - site_settings.yml - defaults, but can be set via UI and saved in DB
    - database.yml - does not seem needed
- https://edgeryders.eu/t/discourse-admin-manual/6647

### podman

to start a shell in the pod:

      podman run -it --pod discourse-kiss alpine

### redis

to configure the password:

      docker-compose run redis redis-cli -h redis
      redis:6379> config set requirepass password123

### postgresql

shell client:

      docker-compose exec -u 0 postgresql psql -U postgres

reference
- [entrypoint.sh](https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh).
- initdb cannot be run as root

## Image Notes

webserver
- Unicorn is a Rack HTTP server to serve Ruby web applications
- with podman/compose examples, exposed at http://localhost:8013/forum

## Related

### Official Launcher

[repo](https://github.com/discourse/discourse_docker)
/
[image](https://hub.docker.com/r/discourse/base)

Compared to the official method *discourse-kiss*:

- -a smaller image: XXX vs 1GB- (TODO)
- works with plain any standard OCI runtime, like k8s.
- doesn't require a custom "templating" system

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

