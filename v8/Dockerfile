# Get V8 source
FROM debian:buster-slim AS source

ENV PATH $PATH:/tmp/depot_tools
WORKDIR /usr/local/src

RUN apt-get update && \
    apt-get install -y bzip2 curl git g++ pkg-config python2.7 libicu-dev libpq-dev zlib1g-dev && \
    ln -s /usr/bin/python2.7 /usr/bin/python2 && \
    ln -s /usr/bin/python2.7 /usr/bin/python
RUN git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools
RUN fetch --no-history v8

# Build V8 source
FROM alpine:3.11 AS build

WORKDIR /usr/local/src
COPY --from=source /usr/local/src /usr/local/src

RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted gn && \
    apk add --no-cache g++ gcc glib-dev icu-dev libstdc++ linux-headers make ninja pkgconf python2 && \
    ln -sf /usr/bin/gn /usr/local/src/v8/buildtools/linux64/gn
RUN cd v8 && \
    tools/dev/v8gen.py x64.release -- is_component_build=true is_cfi=false is_clang=false is_official_build=true use_custom_libcxx=false use_gold=false use_sysroot=false && \
    ln -sf /usr/bin/python2 /usr/bin/python3 && \
    ninja -C out.gn/x64.release -j $(getconf _NPROCESSORS_ONLN) d8
RUN cd v8 && \
    mkdir -p /v8/include /v8/lib && \
    cp -R include/* /v8/include && \
    cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin out.gn/x64.release/icudtl.dat /v8/lib

FROM php:7.4-fpm-alpine

COPY --from=build /v8/ /usr/v8/

# Install PHP extensions
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS git icu-dev imagemagick-dev libzip-dev postgresql-dev && \
    git clone https://github.com/phpv8/v8js.git /tmp/v8js && \
    cd /tmp/v8js && \
    phpize && \
    ./configure --with-v8js=/usr/v8 LDFLAGS="-lstdc++" && \
    make && \
    make install && \
    rm -r /tmp/v8js && \
    docker-php-ext-install bcmath exif intl pcntl pdo pdo_pgsql zip && \
    pecl install apcu imagick redis xdebug && \
    docker-php-ext-enable apcu imagick redis v8js && \
    apk add --no-cache icu imagemagick libpq libzip && \
    apk del .phpize-deps

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xzC /usr/local/bin
