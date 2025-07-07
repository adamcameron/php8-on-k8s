FROM php:8.4.10-fpm-bookworm

RUN ["apt-get", "update"]
RUN ["apt-get", "install", "-y", "zip", "unzip", "git", "vim"]

RUN echo "alias ll='ls -alF'" >> ~/.bashrc
RUN echo "alias cls='clear; printf \"\033[3J\"'" >> ~/.bashrc

RUN cp /usr/local/etc/php/php.ini-development /usr/local/etc/php/php.ini
COPY usr/local/etc/php/conf.d/php8-on-k8s.ini /usr/local/etc/php/conf.d/php8-on-k8s.ini

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

RUN pecl install xdebug && docker-php-ext-enable xdebug
COPY usr/local/etc/php/conf.d/xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
COPY usr/local/etc/php/conf.d/error_reporting.ini /usr/local/etc/php/conf.d/error_reporting.ini

RUN apt-get install -y libicu-dev && docker-php-ext-configure intl && docker-php-ext-install intl

RUN [ \
    "apt-get", "install", "-y",  \
    "libz-dev", \
    "libzip-dev", \
    "libfcgi0ldbl" \
]
RUN docker-php-ext-configure zip && docker-php-ext-install zip
RUN docker-php-ext-configure pdo_mysql && docker-php-ext-install pdo_mysql
RUN docker-php-ext-configure opcache && docker-php-ext-install opcache

RUN curl -1sLf 'https://dl.cloudsmith.io/public/symfony/stable/setup.deb.sh' | bash
RUN ["apt-get", "install", "-y", "symfony-cli"]

RUN git config --global --add safe.directory /var/www

RUN mkdir -p /var/cache && chown www-data:www-data /var/cache && chmod 775 /var/cache
RUN mkdir -p /var/log && chown www-data:www-data /var/log && chmod 775 /var/log

HEALTHCHECK \
    --start-period=30s \
    --interval=30s \
    --timeout=3s \
    --retries=3 \
    CMD SCRIPT_FILENAME=/var/www/bin/healthCheck.php REQUEST_METHOD=GET cgi-fcgi -bind -connect localhost:9000 | grep 'pong' || exit 1

WORKDIR /var/www
ENV COMPOSER_ALLOW_SUPERUSER 1

COPY --chmod=755 usr/local/bin/entrypoint.sh /usr/local/bin/
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 9000
