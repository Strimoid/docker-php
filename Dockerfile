FROM dunglas/frankenphp:1.1-php8.3-alpine

# Install PHP extensions
RUN install-php-extensions \
    apcu \
    bcmath \
    exif \
    imagick \
    intl \
    opcache \
    pcntl \
    pdo \
    pdo_pgsql \
    redis \
    xdebug \
    zip

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install Dockerize
ENV DOCKERIZE_VERSION v0.7.0
RUN curl -SL https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    | tar xzC /usr/local/bin
