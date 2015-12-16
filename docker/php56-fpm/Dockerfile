FROM        php:5.6-fpm
MAINTAINER  Bart Reunes "@MetalArend"

# Install packages
RUN apt-get update \
    && apt-get install -y \
        libfreetype6-dev libjpeg62-turbo-dev libpng12-dev \
        libmcrypt-dev \
        zlib1g-dev \
        libicu-dev g++ \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-configure intl \
    && docker-php-ext-install \
        gd \
        mcrypt \
        zip \
        mbstring \
        intl \
        mysql mysqli pdo_mysql #pdo pdo_mysql
RUN pecl install xdebug apc
# other packages: php5-imagick php-pear

# Install phpunit, phpcs, phpdoc and composer
RUN apt-get install -y git \
    && curl -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar \
    && curl -o /usr/bin/phpcs https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && curl -o /usr/bin/phpcbf https://squizlabs.github.io/PHP_CodeSniffer/phpcbf.phar \
    && curl -o /usr/bin/phpdoc http://phpdoc.org/phpDocumentor.phar \
    && curl -o /usr/bin/composer https://getcomposer.org/composer.phar \
    && chmod +x /usr/bin/phpunit /usr/bin/phpcs /usr/bin/phpcbf /usr/bin/composer /usr/bin/phpdoc

# Clean image
RUN apt-get autoremove -yq --purge \
    && apt-get clean \
    && apt-get -f install \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# Add configuration
ADD . /container
RUN cp /container/conf/php.ini /usr/local/etc/php
RUN cp /container/conf/php-fpm.conf /usr/local/etc/php-fpm.conf
