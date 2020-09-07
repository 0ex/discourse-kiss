FROM discourse/base:release

WORKDIR /var/www/discourse

RUN bundle exec rake plugin:pull_compatible_all

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]


