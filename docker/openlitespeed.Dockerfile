FROM litespeedtech/openlitespeed:1.7.16-lsphp81

# Instead of using `php-config` let's hard code these
ENV PHP_EXT_DIR=/usr/local/lsws/lsphp81/lib/php/20210902
ENV PHP_INI_DIR=/usr/local/lsws/lsphp81/etc/php/8.1/mods-available/

ARG RELAY=v0.7.0

# Install Relay dependencies
RUN apt-get update \
  && apt-get install -y \
  gcc \
  make \
  libssl-dev \
  libck0

RUN curl -L https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz | tar -xzC /usr/src \
  && PREFIX=/usr USE_SSL=1 make -C /usr/src/hiredis-1.2.0 install

# Download Relay
RUN PLATFORM=$(uname -m | sed 's/_/-/') \
  && curl -L "https://builds.r2.relay.so/$RELAY/relay-$RELAY-php8.1-debian-$PLATFORM%2Blibssl3.tar.gz" | tar xz -C /tmp

# Copy relay.{so,ini}
RUN PLATFORM=$(uname -m | sed 's/_/-/') \
  && cp "/tmp/relay-$RELAY-php8.1-debian-$PLATFORM+libssl3/relay.ini" "$PHP_INI_DIR/60-relay.ini" \
  && cp "/tmp/relay-$RELAY-php8.1-debian-$PLATFORM+libssl3/relay.so" "$PHP_EXT_DIR/relay.so"

# Inject UUID
RUN sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" "$PHP_EXT_DIR/relay.so"

# Don't start `lswsctrl`
ENTRYPOINT [""]
