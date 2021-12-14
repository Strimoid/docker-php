FROM strimoid/v8 AS v8

FROM php:8.1-fpm-alpine

COPY --from=v8 /v8/ /usr/v8/

# Install PHP extensions
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS git icu-dev imagemagick-dev libzip-dev postgresql-dev && \
    git clone https://github.com/phpv8/v8js.git /tmp/v8js && \
    cd /tmp/v8js && \
    phpize && \
    ./configure --with-v8js=/usr/v8 LDFLAGS="-lstdc++" && \
    make && \
    make install && \
    rm -r /tmp/v8js && \
    docker-php-ext-install bcmath exif intl opcache pcntl pdo pdo_pgsql zip && \
    pickle install apcu && \
    pickle install imagick && \
    pickle install redis && \
    # pickle install xdebug && \
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
