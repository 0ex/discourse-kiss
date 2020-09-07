FROM discourse/base:2.0.20200906-2310

WORKDIR /var/www/discourse

RUN bundle exec rake plugin:pull_compatible_all

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]


