FROM php:7.1-fpm

# Build V8
RUN apt-get update && \
    apt-get install -y bzip2 git g++ python2.7 libicu-dev libmagickwand-dev zlib1g-dev && \
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools && \
    export PATH="$PATH:/tmp/depot_tools" && \
    cd /usr/local/src && \
    fetch v8 && \
    cd v8 && \
    git checkout 5.9.196 && \
    gclient sync && \
    tools/dev/v8gen.py x64.release -- is_component_build=true && \
    ninja -C out.gn/x64.release && \
    cd /usr/local/src/v8 && \
    mkdir -p /usr/{lib,include} && \
    cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin /usr/lib && \
    cp -R include/* /usr/include && \
    cd out.gn/x64.release/obj && \
    ar rcsDT libv8_libplatform.a v8_libplatform/*.o && \
    echo "create /usr/lib/libv8_libplatform.a\naddlib /usr/local/src/v8/out.gn/x64.release/obj/libv8_libplatform.a\nsave\nend" | ar -M && \
    rm -rf /tmp/depot_tools /usr/local/src/v8

# Install PHP extensions
RUN docker-php-ext-install exif intl pcntl pdo pdo_mysql zip && \
    pecl install apcu imagick v8js && \
    docker-php-ext-enable apcu imagick v8js

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dockerize
ENV DOCKERIZE_VERSION v0.4.0
RUN curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xzC /usr/local/bin
