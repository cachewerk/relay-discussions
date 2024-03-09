FROM debian:10.10

RUN apt-get update

RUN apt-get install -y \
  gnupg \
  lsb-release \
  apt-transport-https \
  ca-certificates \
  software-properties-common \
  curl

RUN curl "https://packages.sury.org/php/apt.gpg" | apt-key add -
RUN add-apt-repository "deb https://packages.sury.org/php/ $(lsb_release -sc) main"
RUN add-apt-repository "deb http://deb.debian.org/debian $(lsb_release -sc)-backports main"
RUN apt-get update

# Fix `php-config` link to `sed`
RUN ln -s /bin/sed /usr/bin/sed

RUN apt-get install -y \
  php8.1-dev



# Install Relay dependencies
RUN apt-get install -y \
  lz4 \
  zstd \
  libssl-dev \
  libck0 \
  php8.1-msgpack \
  php8.1-igbinary

ARG RELAY=v0.7.0

RUN curl -L https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz | tar -xzC /usr/src \
  && PREFIX=/usr USE_SSL=1 make -C /usr/src/hiredis-1.2.0 install

# Download Relay
RUN PLATFORM=$(uname -m | sed 's/_/-/') \
  && curl "https://builds.r2.relay.so/$RELAY/relay-$RELAY-php8.1-debian-$PLATFORM.tar.gz" | tar xz -C /tmp

# Copy relay.{so,ini}
RUN PLATFORM=$(uname -m | sed 's/_/-/') \
  && cp "/tmp/relay-$RELAY-php8.1-debian-$PLATFORM/relay.ini" $(php-config --ini-dir)/30-relay.ini \
  && cp "/tmp/relay-$RELAY-php8.1-debian-$PLATFORM/relay.so" $(php-config --extension-dir)/relay.so

# Inject UUID
RUN sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" $(php-config --extension-dir)/relay.so
