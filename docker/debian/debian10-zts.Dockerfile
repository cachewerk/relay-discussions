FROM --platform=linux/amd64 debian:10

RUN apt-get update && \
  apt-get install -y \
    build-essential \
    autoconf \
    curl \
    git

WORKDIR /tmp/

ARG PHP=8.1.2

# Install PHP-ZTS from source
RUN curl --output php-${PHP}.tar.gz https://www.php.net/distributions/php-${PHP}.tar.gz && \
  tar -xf php-${PHP}.tar.gz && cd php-${PHP} && \
  git clone --depth 1 --branch 3.2.6 https://github.com/igbinary/igbinary ext/igbinary && \
  git clone --depth 1 --branch msgpack-2.1.2 https://github.com/msgpack/msgpack-php ext/msgpack && \
  ./buildconf --force && \
  ./configure \
    --enable-zts \
    --disable-all \
    --enable-json \
    --enable-igbinary \
    --with-msgpack && \
  make -j$(nproc) && \
  make install

ARG RELAY=v0.7.0

RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> '/etc/apt/sources.list'

RUN apt-get update && \
    apt-get install -y \
    libssl-dev \
    libck0

RUN curl -L https://github.com/redis/hiredis/archive/refs/tags/v1.2.0.tar.gz | tar -xzC /usr/src \
  && PREFIX=/usr USE_SSL=1 make -C /usr/src/hiredis-1.2.0 install

# Download Relay
RUN PHP=$(php -r "echo substr(PHP_VERSION, 0, 3);") \
  && curl -L "https://builds.r2.relay.so/$RELAY/relay-$RELAY-php$PHP-debian-x86-64%2Bzts.tar.gz" | tar xz -C /tmp \
  && cd /tmp/relay-* \
  && sed -i "s/00000000-0000-0000-0000-000000000000/$(cat /proc/sys/kernel/random/uuid)/" relay.so \
  && mkdir -p $(php-config --extension-dir) \
  && cp relay.so $(php-config --extension-dir)/relay.so \
  && cat relay.ini >> $(php-config --ini-path)/php.ini
