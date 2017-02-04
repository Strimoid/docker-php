FROM php:7.1-fpm

RUN apt-get update && apt-get install -y bzip2 git g++ python2.7 libicu-dev libmagickwand-dev zlib1g-dev

# Build V8
RUN git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /tmp/depot_tools
RUN export PATH="$PATH:/tmp/depot_tools" && \
    cd /usr/local/src && fetch v8 && cd v8 && git checkout -b 5.7 -t branch-heads/5.7 && gclient sync && \
    tools/dev/v8gen.py x64.release -- is_component_build=true && ninja -C out.gn/x64.release && \
    cd /usr/local/src/v8 && mkdir -p /usr/v8/include /usr/v8/lib && \
    cp out.gn/x64.release/lib*.so /usr/v8/lib && cp -R include/* /usr/v8/include && \
    cp out.gn/x64.release/natives_blob.bin /usr/v8/lib && cp out.gn/x64.release/snapshot_blob.bin /usr/v8/lib && \
    rm -rf /tmp/depot_tools /usr/local/src/v8 && \
    apt-get remove -y bzip2 git python2.7 && apt-get autoremove -y && apt-get clean

# Install PHP extensions
RUN docker-php-ext-install exif intl pcntl pdo pdo_mysql zip
RUN export V8_DIR=/usr/v8 && pecl install apcu imagick v8js && docker-php-ext-enable apcu imagick v8js

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dockerize
ENV DOCKERIZE_VERSION v0.3.0
RUN curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xzC /usr/local/bin
