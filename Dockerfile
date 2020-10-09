FROM php:8.0-fpm-alpine

# Install pickle
ENV PICKLE_VERSION=0.6.0
RUN curl -Lo /usr/local/bin/pickle https://github.com/FriendsOfPHP/pickle/releases/download/v$PICKLE_VERSION/pickle.phar && \
    chmod +x /usr/local/bin/pickle

# Install PHP extensions
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS git icu-dev imagemagick-dev libzip-dev postgresql-dev && \
    docker-php-ext-install bcmath exif intl opcache pcntl pdo pdo_pgsql zip && \
    pickle install apcu && \
    pickle install redis && \
    # pickle install xdebug && \
    git clone https://github.com/Imagick/imagick && \
    cd imagick && \
    phpize && \
    ./configure && \
    make && \
    make install && \
    cd .. && \
    rm -r imagick && \
    docker-php-ext-enable apcu imagick redis && \
    apk add --no-cache icu imagemagick libpq libzip && \
    apk del .phpize-deps

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xzC /usr/local/bin
