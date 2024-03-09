FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt-get install -y \
  ca-certificates \
  apt-transport-https

RUN apt-get install -y \
  php-dev \
  php-fpm

# Install Relay dependencies
RUN apt-get install -y \
  libck0 \
  php-msgpack \
  php-igbinary

ARG RELAY=v0.7.0

RUN curl -L https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz | tar -xzC /usr/src \
  && PREFIX=/usr USE_SSL=1 make -C /usr/src/hiredis-1.2.0 install

# Download Relay
RUN ARCH=$(uname -m | sed 's/_/-/') \
  PHP=$(php -r 'echo substr(PHP_VERSION, 0, 3);') \
  && curl -L "https://builds.r2.relay.so/$RELAY/relay-$RELAY-php$PHP-debian-$ARCH.tar.gz" | tar xz --strip-components=1 -C /tmp

# Copy relay.{so,ini}
RUN cp "/tmp/relay.ini" $(php-config --ini-dir)/30-relay.ini \
  && cp "/tmp/relay-pkg.so" $(php-config --extension-dir)/relay.so

# Inject UUID
RUN sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" $(php-config --extension-dir)/relay.so
