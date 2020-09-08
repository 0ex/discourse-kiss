FROM discourse/base:release

WORKDIR /var/www/discourse

RUN bundle exec rake plugin:pull_compatible_all

RUN cd plugins \
    && git clone https://github.com/Mbond65/discourse_user_auto_activation

ADD entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]

