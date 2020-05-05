FROM debian:buster-slim AS build

# Build V8
RUN apt-get update && \
    apt-get install -y bzip2 curl git g++ pkg-config python2.7 libicu-dev libpq-dev zlib1g-dev && \
    ln -s /usr/bin/python2.7 /usr/bin/python2 && \
    ln -s /usr/bin/python2.7 /usr/bin/python
RUN git clone --depth=1 https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools

ENV PATH $PATH:/tmp/depot_tools
WORKDIR /usr/local/src

RUN fetch --no-history v8
RUN cd v8 && \
    tools/dev/v8gen.py x64.release -- is_component_build=true use_custom_libcxx=false && \
    ninja -C out.gn/x64.release
RUN cd v8 && \
    mkdir -p /v8/include /v8/lib && \
    cp -R include/* /v8/include && \
    cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin out.gn/x64.release/icudtl.dat /v8/lib

FROM php:7.4-apache

RUN apt-get update && \
    apt-get install -y bzip2 git g++ libicu-dev libmagickwand-dev libpq-dev libzip-dev unzip zlib1g-dev

COPY --from=build /v8/ /usr/

# Install PHP v8js extension
RUN cd /tmp/ && \
    git clone https://github.com/phpv8/v8js.git && \
    cd v8js && \
    phpize && \
    ./configure --with-v8js=/usr LDFLAGS="-lstdc++" && \
    make && \
    make install && \
    rm -r /tmp/v8js

# Install PHP extensions
RUN docker-php-ext-install bcmath exif intl pcntl pdo pdo_mysql pdo_pgsql zip && \
    pecl install apcu imagick redis xdebug && \
    docker-php-ext-enable apcu imagick redis v8js

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xzC /usr/local/bin
