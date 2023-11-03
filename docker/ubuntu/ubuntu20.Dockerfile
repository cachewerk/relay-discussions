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
  php-msgpack \
  php-igbinary

ARG RELAY=v0.6.8

ARG PHP=$(php -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION;')

# Download Relay
RUN ARCH=$(uname -m | sed 's/_/-/') \
  && curl -L "https://builds.r2.relay.so/$RELAY/relay-$RELAY-php$PHP-debian-$ARCH.tar.gz" | tar xz -C /tmp

# Copy relay.{so,ini}
RUN ARCH=$(uname -m | sed 's/_/-/') \
  && cp "/tmp/relay-$RELAY-php$PHP-debian-$ARCH/relay.ini" $(php-config --ini-dir)/30-relay.ini \
  && cp "/tmp/relay-$RELAY-php$PHP-debian-$ARCH/relay-pkg.so" $(php-config --extension-dir)/relay.so

# Inject UUID
RUN sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" $(php-config --extension-dir)/relay.so
