FROM dunglas/frankenphp:1.10-php8.5-alpine

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
    xdebug/xdebug@3.5.0alpha3 \
    zip

# Install Composer
ENV COMPOSER_ALLOW_SUPERUSER 1
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
