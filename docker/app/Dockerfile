FROM composer as build
ENV DOCKERIZE_VERSION=v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
 && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

FROM php:8.0-fpm-alpine

ENV TZ Asia/Tokyo
ENV COMPOSER_ALLOW_SUPERUSER 1

COPY --from=build /usr/bin/composer /usr/bin/composer
COPY --from=build /usr/local/bin/dockerize /usr/bin/dockerize

# package install and setup
RUN set -eux \
 && apk add --update-cache --no-cache openssl git autoconf g++ nodejs npm yarn postgresql-dev libtool make libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev \
 && pecl install redis \
 && docker-php-ext-configure gd --with-jpeg=/usr \
 && docker-php-ext-configure opcache --enable-opcache \
 && docker-php-ext-install gd pdo_pgsql pgsql opcache bcmath gd exif zip \
 && docker-php-ext-enable redis \
 && apk del autoconf g++ libtool make && rm -rf /tmp/*

# project
ARG PROJECT_NAME
COPY ./src/storage /$PROJECT_NAME/storage
