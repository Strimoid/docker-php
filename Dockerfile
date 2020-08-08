FROM php:7.4-fpm-alpine

# Install PHP extensions
RUN apk add --no-cache --virtual .phpize-deps $PHPIZE_DEPS icu-dev imagemagick-dev libzip-dev postgresql-dev && \
    docker-php-ext-install bcmath exif intl opcache pcntl pdo pdo_pgsql zip && \
    pecl install apcu imagick redis xdebug && \
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
