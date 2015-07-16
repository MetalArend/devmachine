FROM        php:5.4-fpm
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
RUN pecl install xdebug
# other packages: php5-imagick php-pear

# Install phpunit, phpcs, phpdoc and composer
RUN apt-get install -y git \
    && curl -o /usr/bin/phpunit https://phar.phpunit.de/phpunit.phar \
    && curl -o /usr/bin/phpcs https://squizlabs.github.io/PHP_CodeSniffer/phpcs.phar \
    && curl -o /usr/bin/phpdoc http://phpdoc.org/phpDocumentor.phar \
    && curl -o /usr/bin/composer https://getcomposer.org/composer.phar \
    && chmod +x /usr/bin/phpunit /usr/bin/phpcs /usr/bin/composer /usr/bin/phpdoc

# Clean image
RUN apt-get autoremove -yq --purge \
    && apt-get clean \
    && apt-get -f install \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /tmp/* /var/tmp/*

# Install composer
#RUN curl -sS https://getcomposer.org/installer | php -- --quiet --install-dir=/usr/bin/ && mv /usr/bin/composer.phar /usr/bin/composer

# Add configuration
ADD . /container
RUN cp /container/conf/php.ini /usr/local/etc/php

# --- --- ---
# Configure php5-fpm
#RUN sed -i '/^error_log = /c\error_log = \/log\/\error54.log' /etc/php5/fpm/php-fpm.conf && \
#    sed -i '/^;access.log = /c\access.log = \/log\/access54.log' /etc/php5/fpm/pool.d/www.conf && \
#    sed -i '/^;pm.status_path = /c\pm.status_path = \/status' /etc/php5/fpm/pool.d/www.conf && \
#    sed -i '/^;ping.path = /c\ping.path = \/ping' /etc/php5/fpm/pool.d/www.conf && \
#    sed -i '/^listen /c\listen = 9000' /etc/php5/fpm/pool.d/www.conf && \
#    sed -i 's/^listen.allowed_clients/;listen.allowed_clients/' /etc/php5/fpm/pool.d/www.conf && \
#    sed -i '/daemonize /c\daemonize = no' /etc/php5/fpm/php-fpm.conf # fpm conf
#RUN sed -i 's/;pm.start_servers/pm.start_servers/g' /etc/php5/fpm/pool.d/www.conf
# --- --- ---
#RUN cp /etc/apache2/mods-available/rewrite.load /etc/apache2/mods-enabled/rewrite.load
# --- --- ---
